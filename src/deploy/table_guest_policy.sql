BEGIN;

GRANT SELECT, UPDATE ON TABLE vibetype.guest TO vibetype_account, vibetype_anonymous;
GRANT INSERT, DELETE ON TABLE vibetype.guest TO vibetype_account;

ALTER TABLE vibetype.guest ENABLE ROW LEVEL SECURITY;

CREATE FUNCTION vibetype_private.guest_policy_select(g vibetype.guest) RETURNS boolean
AS $$
  SELECT (
    -- Display guests accessible through guest claims.
    g.id = ANY (vibetype.guest_claim_array())
  OR
  (
    -- Display guests where the contact is the invoker account.
    EXISTS (
      SELECT 1
      FROM vibetype.contact c
      WHERE c.id = g.contact_id
      AND c.account_id = vibetype.invoker_account_id()
      -- omit contacts created by a user who is blocked by the invoker
      -- omit contacts created by a user who blocked the invoker.
      AND NOT EXISTS (
        SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = c.created_by
      )
    )
  )
  OR
  (
    -- Display guests to events organized by the invoker,
    -- but omit guests with contacts pointing at a user blocked by the invoker or pointing at a user who blocked the invoker.
    -- Also omit guests created by a user blocked by the invoker or created by a user who blocked the invoker.
    EXISTS (
      SELECT 1
      FROM vibetype.event e
      WHERE e.id = g.event_id
        AND e.created_by = vibetype.invoker_account_id()
    )
    AND
    EXISTS (
      SELECT 1
      FROM vibetype.contact c
      WHERE c.id = g.contact_id
        AND NOT EXISTS (
          SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = c.account_id
        )
        AND NOT EXISTS (
          SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = c.created_by
        )
    )
  )
);
$$ LANGUAGE sql STABLE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION vibetype_private.guest_policy_select(vibetype.guest) TO vibetype_account, vibetype_anonymous;

CREATE POLICY guest_select ON vibetype.guest FOR SELECT
USING (vibetype_private.guest_policy_select(guest));

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
  (
    vibetype.event_guest_count_maximum(guest.event_id) IS NULL
    OR
    vibetype.event_guest_count_maximum(guest.event_id) > vibetype.guest_count(guest.event_id)
  )
  AND
    EXISTS (
      SELECT 1
      FROM vibetype.contact c
      WHERE c.id = guest.contact_id
      AND c.created_by = vibetype.invoker_account_id()
      AND NOT EXISTS (
        SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = c.account_id
      )
    )
);

CREATE POLICY guest_update ON vibetype.guest FOR UPDATE
USING (vibetype_private.guest_policy_select(guest));

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

CREATE FUNCTION vibetype.trigger_guest_update() RETURNS TRIGGER AS $$
DECLARE
  whitelisted_cols TEXT[] := ARRAY['feedback', 'feedback_paper'];
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
    AND
      EXISTS (
        SELECT 1
          FROM jsonb_each(to_jsonb(OLD)) AS pre, jsonb_each(to_jsonb(NEW)) AS post
          WHERE pre.key = post.key AND pre.value IS DISTINCT FROM post.value
          AND NOT (pre.key = ANY(whitelisted_cols))
      )
  THEN
    RAISE 'You''re only allowed to alter these rows: %!', whitelisted_cols USING ERRCODE = 'insufficient_privilege';
  ELSE
    NEW.updated_at = CURRENT_TIMESTAMP;
    NEW.updated_by = vibetype.invoker_account_id();
    RETURN NEW;
  END IF;
END $$ LANGUAGE plpgsql STRICT VOLATILE SECURITY INVOKER;

COMMENT ON FUNCTION vibetype.trigger_guest_update() IS 'Checks if the caller has permissions to alter the desired columns.';

GRANT EXECUTE ON FUNCTION vibetype.trigger_guest_update() TO vibetype_account, vibetype_anonymous;

CREATE TRIGGER vibetype_guest_update
  BEFORE UPDATE
  ON vibetype.guest
  FOR EACH ROW
  EXECUTE PROCEDURE vibetype.trigger_guest_update();

COMMIT;
