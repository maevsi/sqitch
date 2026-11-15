BEGIN;

-- Every producer skips recipients that blocked the actor or that the actor blocked.
-- A `NULL` actor never matches `account_block`, so anonymous actions are never skipped.

CREATE FUNCTION vibetype_private.trigger_account_notification_event_deleted() RETURNS TRIGGER
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
BEGIN
  -- Joining the creator's account skips deletions cascading from the creator's own account deletion, as the account is gone by then.
  INSERT INTO vibetype.account_notification (account_id, type, actor_account_id, payload)
  SELECT
    c.account_id,
    'event_deleted'::vibetype.notification_type,
    OLD.created_by,
    jsonb_build_object(
      'actor_username', a.username,
      'event_creator_username', a.username,
      'event_name', OLD.name,
      'event_slug', OLD.slug,
      'event_start', OLD.start
    )
  FROM vibetype.guest g
  JOIN vibetype.contact c ON c.id = g.contact_id
  JOIN vibetype.account a ON a.id = OLD.created_by
  WHERE g.event_id = OLD.id
    AND c.account_id IS NOT NULL
    AND c.account_id <> OLD.created_by
    AND g.feedback IS DISTINCT FROM 'canceled'::vibetype.invitation_feedback
    AND NOT EXISTS (
      SELECT 1 FROM vibetype.account_block b
      WHERE (b.created_by = OLD.created_by AND b.blocked_account_id = c.account_id)
        OR (b.created_by = c.account_id AND b.blocked_account_id = OLD.created_by)
    );

  RETURN OLD;
END;
$$;

COMMENT ON FUNCTION vibetype_private.trigger_account_notification_event_deleted() IS 'Notifies the guests of an event, who did not cancel, about its deletion.';
REVOKE ALL ON FUNCTION vibetype_private.trigger_account_notification_event_deleted() FROM PUBLIC;

CREATE TRIGGER notification_event_deleted
  BEFORE
    DELETE
  ON vibetype.event
  FOR EACH ROW
  EXECUTE FUNCTION vibetype_private.trigger_account_notification_event_deleted();


CREATE FUNCTION vibetype_private.trigger_account_notification_event_invitation() RETURNS TRIGGER
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
BEGIN
  DELETE FROM vibetype.account_notification n
  WHERE n.guest_id = NEW.aggregate_id
    AND n.type = 'event_invitation'::vibetype.notification_type
    AND n.read_at IS NULL;

  INSERT INTO vibetype.account_notification (account_id, type, actor_account_id, event_id, guest_id, payload)
  SELECT
    c.account_id,
    'event_invitation'::vibetype.notification_type,
    e.created_by,
    e.id,
    g.id,
    jsonb_build_object(
      'actor_username', a.username,
      'event_creator_username', a.username,
      'event_name', e.name,
      'event_slug', e.slug,
      'event_start', e.start
    )
  FROM vibetype.guest g
  JOIN vibetype.contact c ON c.id = g.contact_id
  JOIN vibetype.event e ON e.id = g.event_id
  JOIN vibetype.account a ON a.id = e.created_by
  WHERE g.id = NEW.aggregate_id
    AND c.account_id IS NOT NULL
    AND c.account_id <> e.created_by
    AND NOT EXISTS (
      SELECT 1 FROM vibetype.account_block b
      WHERE (b.created_by = e.created_by AND b.blocked_account_id = c.account_id)
        OR (b.created_by = c.account_id AND b.blocked_account_id = e.created_by)
    );

  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION vibetype_private.trigger_account_notification_event_invitation() IS 'Notifies the invited account about a `guest.invited` outbox event and replaces the guest''s earlier unread invitation notification.';
REVOKE ALL ON FUNCTION vibetype_private.trigger_account_notification_event_invitation() FROM PUBLIC;

CREATE TRIGGER notification_event_invitation
  AFTER
    INSERT
  ON vibetype_private.outbox
  FOR EACH ROW
  WHEN (NEW.type = 'guest.invited')
  EXECUTE FUNCTION vibetype_private.trigger_account_notification_event_invitation();


-- Transition tables cannot be combined with a column list, so the function compares the old and new rows itself.
CREATE FUNCTION vibetype_private.trigger_account_notification_event_updated() RETURNS TRIGGER
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
BEGIN
  WITH _changed AS (
    SELECT
      n.id,
      n.created_by,
      n.name,
      n.slug,
      n.start,
      array_remove(ARRAY[
        CASE WHEN n.start IS DISTINCT FROM o.start THEN 'start' END,
        CASE WHEN n."end" IS DISTINCT FROM o."end" THEN 'end' END,
        CASE WHEN n.address_id IS DISTINCT FROM o.address_id THEN 'address' END,
        CASE WHEN n.is_in_person IS DISTINCT FROM o.is_in_person OR n.is_remote IS DISTINCT FROM o.is_remote THEN 'attendance' END
      ], NULL) AS changes
    FROM new_event n
    JOIN old_event o ON o.id = n.id
  ),
  _recipient AS (
    SELECT
      ch.id,
      ch.changes,
      ch.created_by,
      ch.name,
      ch.slug,
      ch.start,
      a.username,
      c.account_id AS recipient_id
    FROM _changed ch
    JOIN vibetype.account a ON a.id = ch.created_by
    JOIN vibetype.guest g ON g.event_id = ch.id
    JOIN vibetype.contact c ON c.id = g.contact_id
    WHERE cardinality(ch.changes) > 0
      AND c.account_id IS NOT NULL
      AND c.account_id <> ch.created_by
      AND g.feedback IS DISTINCT FROM 'canceled'::vibetype.invitation_feedback
      AND NOT EXISTS (
        SELECT 1 FROM vibetype.account_block b
        WHERE (b.created_by = ch.created_by AND b.blocked_account_id = c.account_id)
          OR (b.created_by = c.account_id AND b.blocked_account_id = ch.created_by)
      )
  ),
  _collapsed AS (
    DELETE FROM vibetype.account_notification n
    USING _recipient r
    WHERE n.type = 'event_updated'::vibetype.notification_type
      AND n.read_at IS NULL
      AND n.account_id = r.recipient_id
      AND n.event_id = r.id
    RETURNING n.account_id, n.event_id, n.payload -> 'changes' AS changes
  )
  INSERT INTO vibetype.account_notification (account_id, type, actor_account_id, event_id, payload)
  SELECT
    r.recipient_id,
    'event_updated'::vibetype.notification_type,
    r.created_by,
    r.id,
    jsonb_build_object(
      'actor_username', r.username,
      'changes', (
        SELECT jsonb_agg(DISTINCT u.change ORDER BY u.change)
        FROM (
          SELECT unnest(r.changes) AS change
          UNION ALL
          SELECT jsonb_array_elements_text(d.changes)
          FROM _collapsed d
          WHERE d.account_id = r.recipient_id AND d.event_id = r.id
        ) u
      ),
      'event_creator_username', r.username,
      'event_name', r.name,
      'event_slug', r.slug,
      'event_start', r.start
    )
  FROM _recipient r;

  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION vibetype_private.trigger_account_notification_event_updated() IS 'Notifies the guests of an event, who did not cancel, about changed start, end, address or attendance mode, and merges the changes into their earlier unread notification of the event.';
REVOKE ALL ON FUNCTION vibetype_private.trigger_account_notification_event_updated() FROM PUBLIC;

CREATE TRIGGER notification_event_updated
  AFTER
    UPDATE
  ON vibetype.event
  REFERENCING OLD TABLE AS old_event NEW TABLE AS new_event
  FOR EACH STATEMENT
  EXECUTE FUNCTION vibetype_private.trigger_account_notification_event_updated();


CREATE FUNCTION vibetype_private.trigger_account_notification_friendship_accepted() RETURNS TRIGGER
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
BEGIN
  DELETE FROM vibetype.account_notification n
  WHERE n.friendship_id = NEW.id
    AND n.type = 'friendship_requested'::vibetype.notification_type;

  INSERT INTO vibetype.account_notification (account_id, type, actor_account_id, friendship_id, payload)
  SELECT
    NEW.created_by,
    'friendship_accepted'::vibetype.notification_type,
    NEW.updated_by,
    NEW.id,
    jsonb_build_object('actor_username', a.username)
  FROM (SELECT 1) AS _
  LEFT JOIN vibetype.account a ON a.id = NEW.updated_by
  WHERE NOT EXISTS (
    SELECT 1 FROM vibetype.account_block b
    WHERE (b.created_by = NEW.created_by AND b.blocked_account_id = NEW.updated_by)
      OR (b.created_by = NEW.updated_by AND b.blocked_account_id = NEW.created_by)
  );

  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION vibetype_private.trigger_account_notification_friendship_accepted() IS 'Notifies the requester about the acceptance of a friendship request and removes the accepting account''s request notification.';
REVOKE ALL ON FUNCTION vibetype_private.trigger_account_notification_friendship_accepted() FROM PUBLIC;

CREATE TRIGGER notification_friendship_accepted
  AFTER
    UPDATE OF status
  ON vibetype.friendship
  FOR EACH ROW
  WHEN (OLD.status = 'requested'::vibetype.friendship_status AND NEW.status = 'accepted'::vibetype.friendship_status)
  EXECUTE FUNCTION vibetype_private.trigger_account_notification_friendship_accepted();


CREATE FUNCTION vibetype_private.trigger_account_notification_friendship_requested() RETURNS TRIGGER
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
BEGIN
  INSERT INTO vibetype.account_notification (account_id, type, actor_account_id, friendship_id, payload)
  SELECT
    r.id,
    'friendship_requested'::vibetype.notification_type,
    NEW.created_by,
    NEW.id,
    jsonb_build_object('actor_username', a.username)
  FROM (
    SELECT CASE WHEN NEW.created_by = NEW.a_account_id THEN NEW.b_account_id ELSE NEW.a_account_id END AS id
  ) r
  JOIN vibetype.account a ON a.id = NEW.created_by
  WHERE NOT EXISTS (
    SELECT 1 FROM vibetype.account_block b
    WHERE (b.created_by = NEW.created_by AND b.blocked_account_id = r.id)
      OR (b.created_by = r.id AND b.blocked_account_id = NEW.created_by)
  );

  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION vibetype_private.trigger_account_notification_friendship_requested() IS 'Notifies the addressee of a friendship request.';
REVOKE ALL ON FUNCTION vibetype_private.trigger_account_notification_friendship_requested() FROM PUBLIC;

CREATE TRIGGER notification_friendship_requested
  AFTER
    INSERT
  ON vibetype.friendship
  FOR EACH ROW
  EXECUTE FUNCTION vibetype_private.trigger_account_notification_friendship_requested();


CREATE FUNCTION vibetype_private.trigger_account_notification_guest_feedback() RETURNS TRIGGER
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
BEGIN
  DELETE FROM vibetype.account_notification n
  WHERE n.guest_id = NEW.id
    AND n.type = 'guest_feedback'::vibetype.notification_type
    AND n.read_at IS NULL;

  INSERT INTO vibetype.account_notification (account_id, type, actor_account_id, event_id, guest_id, payload)
  SELECT
    e.created_by,
    'guest_feedback'::vibetype.notification_type,
    NEW.updated_by,
    e.id,
    NEW.id,
    jsonb_build_object(
      'actor_username', au.username,
      'event_creator_username', cu.username,
      'event_name', e.name,
      'event_slug', e.slug,
      'event_start', e.start,
      'feedback', NEW.feedback,
      'guest_name', COALESCE(NULLIF(btrim(concat_ws(' ', c.first_name, c.last_name)), ''), ca.username)
    )
  FROM vibetype.event e
  JOIN vibetype.account cu ON cu.id = e.created_by
  JOIN vibetype.contact c ON c.id = NEW.contact_id
  LEFT JOIN vibetype.account au ON au.id = NEW.updated_by
  LEFT JOIN vibetype.account ca ON ca.id = c.account_id
  WHERE e.id = NEW.event_id
    AND e.created_by IS DISTINCT FROM NEW.updated_by
    AND NOT EXISTS (
      SELECT 1 FROM vibetype.account_block b
      WHERE (b.created_by = e.created_by AND b.blocked_account_id = NEW.updated_by)
        OR (b.created_by = NEW.updated_by AND b.blocked_account_id = e.created_by)
    );

  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION vibetype_private.trigger_account_notification_guest_feedback() IS 'Notifies the event creator about a guest''s feedback and replaces the guest''s earlier unread feedback notification.';
REVOKE ALL ON FUNCTION vibetype_private.trigger_account_notification_guest_feedback() FROM PUBLIC;

CREATE TRIGGER notification_guest_feedback
  AFTER
    UPDATE OF feedback
  ON vibetype.guest
  FOR EACH ROW
  WHEN (NEW.feedback IS DISTINCT FROM OLD.feedback AND NEW.feedback IS NOT NULL)
  EXECUTE FUNCTION vibetype_private.trigger_account_notification_guest_feedback();

COMMIT;
