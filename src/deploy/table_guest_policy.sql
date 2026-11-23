BEGIN;

\set role_service_reccoom_username `cat /run/secrets/postgres-role-service-reccoom-username`

GRANT SELECT ON TABLE vibetype.guest TO vibetype_account, vibetype_anonymous;
-- A guest's event and contact are fixed once created, only the feedback columns are meant to change.
-- Anonymous invokers can never organize an event, so they have no use for the override.
GRANT UPDATE (feedback, feedback_override) ON TABLE vibetype.guest TO vibetype_account;
GRANT UPDATE (feedback) ON TABLE vibetype.guest TO vibetype_anonymous;
GRANT INSERT, DELETE ON TABLE vibetype.guest TO vibetype_account;
GRANT SELECT ON TABLE vibetype.guest TO :role_service_reccoom_username;

ALTER TABLE vibetype.guest ENABLE ROW LEVEL SECURITY;

-- Helper: returns contact IDs referring to the invoker's account, omitting contacts created by a blocked account.
-- Needs SECURITY DEFINER to bypass RLS on the contact table.
CREATE FUNCTION vibetype_private.contacts_referring_invoker() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
  SELECT COALESCE(array_agg(c.id), ARRAY[]::UUID[])
  FROM vibetype.contact c
  WHERE c.account_id = vibetype.invoker_account_id()
    AND NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = c.created_by);
$$;

-- Helper: returns contact IDs created by or pointing at a blocked account.
-- Needs SECURITY DEFINER to bypass RLS on the contact table.
CREATE FUNCTION vibetype_private.contacts_blocked() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
  WITH _blocked AS MATERIALIZED (
    SELECT vibetype_private.account_block_ids() AS ids
  )
  SELECT COALESCE(array_agg(c.id), ARRAY[]::UUID[])
  FROM vibetype.contact c, _blocked
  WHERE c.created_by = ANY (_blocked.ids)
    OR c.account_id = ANY (_blocked.ids);
$$;

-- Helper: returns event IDs for events organized by the invoker.
-- Needs SECURITY DEFINER to skip the event policies, which would otherwise be evaluated for every own event.
CREATE FUNCTION vibetype_private.events_organized() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
  SELECT COALESCE(array_agg(e.id), ARRAY[]::UUID[])
  FROM vibetype.event e
  WHERE e.created_by = vibetype.invoker_account_id();
$$;

GRANT EXECUTE ON FUNCTION vibetype_private.contacts_blocked() TO vibetype_account, vibetype_anonymous;
GRANT EXECUTE ON FUNCTION vibetype_private.contacts_referring_invoker() TO vibetype_account, vibetype_anonymous;
GRANT EXECUTE ON FUNCTION vibetype_private.events_organized() TO vibetype_account, vibetype_anonymous;

-- Display guests accessible through guest claims.
-- Display guests where the contact is the invoker account,
--   omitting contacts created by a blocked account.
-- Display guests to events organized by the invoker,
--   omitting guests with contacts pointing at or created by a blocked account.
CREATE POLICY guest_select ON vibetype.guest FOR SELECT
USING (
  (
    guest.id = ANY ((SELECT vibetype.guest_claim_array())::UUID[])
    OR guest.contact_id = ANY ((SELECT vibetype_private.contacts_referring_invoker())::UUID[])
    OR guest.event_id = ANY ((SELECT vibetype_private.events_organized())::UUID[])
  )
  AND (
    NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.contacts_blocked())) AS c WHERE c = guest.contact_id)
    OR guest.id = ANY ((SELECT vibetype.guest_claim_array())::UUID[])
    OR guest.contact_id = ANY ((SELECT vibetype_private.contacts_referring_invoker())::UUID[])
  )
);

-- Only allow inserts for guests of events organized by oneself.
-- Only allow inserts for guests of events for which the maximum guest count is not yet reached.
-- Only allow inserts for guests for a contact that was created by oneself.
-- Do not allow inserts for guests for a contact referring a blocked account.
-- The counter is read from the event row of an event organized by the invoker, which the `event_all` policy makes visible.
CREATE POLICY guest_insert ON vibetype.guest FOR INSERT
WITH CHECK (
  guest.event_id = ANY ((SELECT vibetype_private.events_organized())::UUID[])
  AND
  COALESCE(
    vibetype.event_guest_count_maximum(guest.event_id) > (SELECT e.guest_count FROM vibetype.event e WHERE e.id = guest.event_id),
    TRUE
  )
  AND
    EXISTS (
      SELECT 1
      FROM vibetype.contact c
      WHERE c.id = guest.contact_id
      AND c.created_by = vibetype.invoker_account_id()
      AND NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.account_block_ids())) AS b WHERE b = c.account_id)
    )
);

CREATE POLICY guest_update ON vibetype.guest FOR UPDATE
USING (
  (
    guest.id = ANY ((SELECT vibetype.guest_claim_array())::UUID[])
    OR guest.contact_id = ANY ((SELECT vibetype_private.contacts_referring_invoker())::UUID[])
    OR guest.event_id = ANY ((SELECT vibetype_private.events_organized())::UUID[])
  )
  AND (
    NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.contacts_blocked())) AS c WHERE c = guest.contact_id)
    OR guest.id = ANY ((SELECT vibetype.guest_claim_array())::UUID[])
    OR guest.contact_id = ANY ((SELECT vibetype_private.contacts_referring_invoker())::UUID[])
  )
);

-- Only allow deletes for guests of events organized by oneself.
CREATE POLICY guest_delete ON vibetype.guest FOR DELETE
USING (
  guest.event_id = ANY ((SELECT vibetype_private.events_organized())::UUID[])
);

CREATE FUNCTION vibetype.trigger_guest_update() RETURNS TRIGGER
    LANGUAGE plpgsql STRICT
    AS $$
DECLARE
  _is_invited BOOLEAN;
  _is_organizer BOOLEAN;
BEGIN
  _is_invited := (
    OLD.id = ANY (vibetype.guest_claim_array())
    OR
    EXISTS (
      SELECT 1
      FROM vibetype.contact c
      WHERE c.id = OLD.contact_id
      AND c.account_id = vibetype.invoker_account_id()
    )
  );
  _is_organizer := EXISTS (
    SELECT 1
    FROM vibetype.event e
    WHERE e.id = OLD.event_id
    AND e.created_by = vibetype.invoker_account_id()
  );

  IF NEW.feedback IS DISTINCT FROM OLD.feedback AND NOT _is_invited THEN
    RAISE 'Only the guest is allowed to alter the feedback, the organizer can set feedback_override instead!' USING ERRCODE = 'insufficient_privilege';
  END IF;

  IF NEW.feedback_override IS DISTINCT FROM OLD.feedback_override AND NOT _is_organizer THEN
    RAISE 'Only the organizer is allowed to alter the feedback override!' USING ERRCODE = 'insufficient_privilege';
  END IF;

  IF
      _is_invited
    AND (
      NEW.id IS DISTINCT FROM OLD.id
      OR NEW.contact_id IS DISTINCT FROM OLD.contact_id
      OR NEW.event_id IS DISTINCT FROM OLD.event_id
      OR NEW.created_at IS DISTINCT FROM OLD.created_at
      OR NEW.updated_at IS DISTINCT FROM OLD.updated_at
      OR NEW.updated_by IS DISTINCT FROM OLD.updated_by
    )
  THEN
    RAISE 'You''re only allowed to alter these columns: feedback, feedback_override!' USING ERRCODE = 'insufficient_privilege';
  END IF;

  NEW.updated_at = CURRENT_TIMESTAMP;
  NEW.updated_by = vibetype.invoker_account_id();
  RETURN NEW;
END $$;
COMMENT ON FUNCTION vibetype.trigger_guest_update() IS 'Checks if the caller has permissions to alter the desired columns: the guest sets the feedback, the organizer sets the feedback override.';
GRANT EXECUTE ON FUNCTION vibetype.trigger_guest_update() TO vibetype_account, vibetype_anonymous;

CREATE TRIGGER update
  BEFORE UPDATE
  ON vibetype.guest
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.trigger_guest_update();

-- Security definer because guest inserters have no update privilege on event.
-- The events are locked in id order before they are updated, so concurrent statements touching several of the same events cannot deadlock.
-- A statement level trigger on a transition table updates every affected event once, even when a cascade removes many guests.
CREATE FUNCTION vibetype_private.trigger_guest_count_insert() RETURNS TRIGGER
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
BEGIN
  PERFORM 1
  FROM vibetype.event
  WHERE id IN (SELECT event_id FROM guest_inserted)
  ORDER BY id
  FOR UPDATE;

  UPDATE vibetype.event
  SET guest_count = event.guest_count + g.guest_count
  FROM (
    SELECT event_id, COUNT(*)::INTEGER AS guest_count
    FROM guest_inserted
    GROUP BY event_id
  ) g
  WHERE event.id = g.event_id;

  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION vibetype_private.trigger_guest_count_insert() IS 'Adds the guests of an insert statement to the guest count of their events.';
REVOKE ALL ON FUNCTION vibetype_private.trigger_guest_count_insert() FROM PUBLIC;

CREATE FUNCTION vibetype_private.trigger_guest_count_delete() RETURNS TRIGGER
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
BEGIN
  PERFORM 1
  FROM vibetype.event
  WHERE id IN (SELECT event_id FROM guest_deleted)
  ORDER BY id
  FOR UPDATE;

  UPDATE vibetype.event
  SET guest_count = event.guest_count - g.guest_count
  FROM (
    SELECT event_id, COUNT(*)::INTEGER AS guest_count
    FROM guest_deleted
    GROUP BY event_id
  ) g
  WHERE event.id = g.event_id;

  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION vibetype_private.trigger_guest_count_delete() IS 'Subtracts the guests of a delete statement from the guest count of their events.';
REVOKE ALL ON FUNCTION vibetype_private.trigger_guest_count_delete() FROM PUBLIC;

CREATE TRIGGER guest_count_insert
  AFTER INSERT
  ON vibetype.guest
  REFERENCING NEW TABLE AS guest_inserted
  FOR EACH STATEMENT
  EXECUTE FUNCTION vibetype_private.trigger_guest_count_insert();

CREATE TRIGGER guest_count_delete
  AFTER DELETE
  ON vibetype.guest
  REFERENCING OLD TABLE AS guest_deleted
  FOR EACH STATEMENT
  EXECUTE FUNCTION vibetype_private.trigger_guest_count_delete();

COMMIT;
