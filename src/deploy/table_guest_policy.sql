BEGIN;

GRANT SELECT, UPDATE ON TABLE vibetype.guest TO vibetype_account, vibetype_anonymous;
GRANT INSERT, DELETE ON TABLE vibetype.guest TO vibetype_account;

ALTER TABLE vibetype.guest ENABLE ROW LEVEL SECURITY;

-- Display guests accessible through guest claims.
-- Display guests where the contact is the invoker account,
--   omitting contacts created by a blocked account.
-- Display guests to events organized by the invoker,
--   omitting guests with contacts pointing at or created by a blocked account.

-- Helper: returns guest IDs where the contact references the invoker's account.
-- Needs SECURITY DEFINER to bypass RLS on guest and contact tables.
CREATE FUNCTION vibetype_private.guests_via_own_contact() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT COALESCE(array_agg(g.id), ARRAY[]::UUID[])
  FROM vibetype.guest g
  JOIN vibetype.contact c ON c.id = g.contact_id
  WHERE c.account_id = vibetype.invoker_account_id()
    AND NOT (c.created_by = ANY(vibetype_private.account_block_ids()));
$$;

-- Helper: returns guest IDs for events organized by the invoker with unblocked contacts.
-- Needs SECURITY DEFINER to bypass RLS on guest, event, and contact tables.
CREATE FUNCTION vibetype_private.guests_via_own_events_unblocked() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  WITH _blocked AS (
    SELECT vibetype_private.account_block_ids() AS ids
  )
  SELECT COALESCE(array_agg(g.id), ARRAY[]::UUID[])
  FROM vibetype.guest g
  JOIN vibetype.event e ON e.id = g.event_id
  JOIN vibetype.contact c ON c.id = g.contact_id,
  _blocked
  WHERE e.created_by = vibetype.invoker_account_id()
    AND (c.account_id IS NULL OR NOT (c.account_id = ANY(_blocked.ids)))
    AND NOT (c.created_by = ANY(_blocked.ids));
$$;

-- Row-level visibility check for newly inserted guests not yet visible to STABLE functions.
-- Only queries contact and event tables (not guest), so works during INSERT+RETURNING.
CREATE FUNCTION vibetype_private.guest_row_visible(contact_id UUID, event_id UUID) RETURNS boolean
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  WITH _blocked AS (
    SELECT vibetype_private.account_block_ids() AS ids
  )
  SELECT (
    EXISTS (
      SELECT 1
      FROM vibetype.contact c, _blocked
      WHERE c.id = guest_row_visible.contact_id
        AND c.account_id = vibetype.invoker_account_id()
        AND NOT (c.created_by = ANY(_blocked.ids))
    )
    OR (
      EXISTS (
        SELECT 1
        FROM vibetype.event e
        WHERE e.id = guest_row_visible.event_id
          AND e.created_by = vibetype.invoker_account_id()
      )
      AND EXISTS (
        SELECT 1
        FROM vibetype.contact c, _blocked
        WHERE c.id = guest_row_visible.contact_id
          AND (c.account_id IS NULL OR NOT (c.account_id = ANY(_blocked.ids)))
          AND NOT (c.created_by = ANY(_blocked.ids))
      )
    )
  );
$$;

GRANT EXECUTE ON FUNCTION vibetype_private.guests_via_own_contact() TO vibetype_account, vibetype_anonymous;
GRANT EXECUTE ON FUNCTION vibetype_private.guests_via_own_events_unblocked() TO vibetype_account, vibetype_anonymous;
GRANT EXECUTE ON FUNCTION vibetype_private.guest_row_visible(UUID, UUID) TO vibetype_account, vibetype_anonymous;

CREATE POLICY guest_select ON vibetype.guest FOR SELECT
USING (
  EXISTS (SELECT 1 FROM unnest(vibetype.guest_claim_array()) AS gc WHERE gc = guest.id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.guests_via_own_contact()) AS g WHERE g = guest.id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.guests_via_own_events_unblocked()) AS g WHERE g = guest.id)
  OR vibetype_private.guest_row_visible(guest.contact_id, guest.event_id)
);

-- Only allow inserts for guests of events organized by oneself.
-- Only allow inserts for guests of events for which the maximum guest count is not yet reached.
-- Only allow inserts for guests for a contact that was created by oneself.
-- Do not allow inserts for guests for a contact referring a blocked account.
CREATE POLICY guest_insert ON vibetype.guest FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1
      FROM vibetype.event e
      WHERE e.id = guest.event_id
        AND e.created_by = vibetype.invoker_account_id()
  )
  AND
  COALESCE(
    vibetype.event_guest_count_maximum(guest.event_id) > vibetype.guest_count(guest.event_id),
    TRUE
  )
  AND
    EXISTS (
      SELECT 1
      FROM vibetype.contact c
      WHERE c.id = guest.contact_id
      AND c.created_by = vibetype.invoker_account_id()
      AND (c.account_id IS NULL OR NOT (c.account_id = ANY(vibetype_private.account_block_ids())))
    )
);

CREATE POLICY guest_update ON vibetype.guest FOR UPDATE
USING (
  EXISTS (SELECT 1 FROM unnest(vibetype.guest_claim_array()) AS gc WHERE gc = guest.id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.guests_via_own_contact()) AS g WHERE g = guest.id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.guests_via_own_events_unblocked()) AS g WHERE g = guest.id)
  OR vibetype_private.guest_row_visible(guest.contact_id, guest.event_id)
);

-- Only allow deletes for guests of events organized by oneself.
CREATE POLICY guest_delete ON vibetype.guest FOR DELETE
USING (
  EXISTS (
    SELECT 1
      FROM vibetype.event e
      WHERE e.id = guest.event_id
        AND e.created_by = vibetype.invoker_account_id()
  )
);

CREATE FUNCTION vibetype.trigger_guest_update() RETURNS TRIGGER
    LANGUAGE plpgsql STRICT
    AS $$
BEGIN
  IF
      TG_OP = 'UPDATE'
    AND ( -- Invited.
      OLD.id = ANY (vibetype.guest_claim_array())
      OR
      EXISTS (
        SELECT 1
        FROM vibetype.contact c
        WHERE c.id = OLD.contact_id
        AND c.account_id = vibetype.invoker_account_id()
      )
    )
    AND (
      NEW.id IS DISTINCT FROM OLD.id
      OR NEW.contact_id IS DISTINCT FROM OLD.contact_id
      OR NEW.event_id IS DISTINCT FROM OLD.event_id
      OR NEW.created_at IS DISTINCT FROM OLD.created_at
      OR NEW.updated_at IS DISTINCT FROM OLD.updated_at
      OR NEW.updated_by IS DISTINCT FROM OLD.updated_by
    )
  THEN
    RAISE 'You''re only allowed to alter these columns: feedback, feedback_paper!' USING ERRCODE = 'insufficient_privilege';
  ELSE
    NEW.updated_at = CURRENT_TIMESTAMP;
    NEW.updated_by = vibetype.invoker_account_id();
    RETURN NEW;
  END IF;
END $$;
COMMENT ON FUNCTION vibetype.trigger_guest_update() IS 'Checks if the caller has permissions to alter the desired columns.';
GRANT EXECUTE ON FUNCTION vibetype.trigger_guest_update() TO vibetype_account, vibetype_anonymous;

CREATE TRIGGER update
  BEFORE UPDATE
  ON vibetype.guest
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.trigger_guest_update();

COMMIT;
