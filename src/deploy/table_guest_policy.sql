BEGIN;

GRANT SELECT, UPDATE ON TABLE vibetype.guest TO vibetype_account, vibetype_anonymous;
GRANT INSERT, DELETE ON TABLE vibetype.guest TO vibetype_account;

ALTER TABLE vibetype.guest ENABLE ROW LEVEL SECURITY;

-- Only display guests accessible through guest claims.
-- Only display guests accessible through the account, omit guests created by a blocked user.
-- Only display guests of events organized by oneself, omit guests created by a blocked user and guests issued for a blocked user.
CREATE POLICY guest_select ON vibetype.guest FOR SELECT USING (
    id = ANY (vibetype.guest_claim_array())
  OR
  (
    contact_id IN (
      SELECT id
      FROM vibetype.contact
      WHERE account_id = vibetype.invoker_account_id()

      EXCEPT

      -- contacts created by a blocked account
      SELECT c.id
      FROM vibetype.contact c
        JOIN vibetype.account_block b
        ON
          c.account_id = b.created_by
          AND
          c.created_by = b.blocked_account_id
      WHERE
        c.account_id = vibetype.invoker_account_id()
    )
  )
  OR
  (
      event_id IN (SELECT vibetype.events_organized())
    AND
      contact_id IN (
        SELECT c.id
        FROM vibetype.contact c
        WHERE
            c.account_id IS NULL
          OR
            c.account_id NOT IN (
              SELECT id FROM vibetype_private.account_block_ids()
            )
      )
  )
);

-- Only allow inserts for guests of events organized by oneself.
-- Only allow inserts for guests of events for which the maximum guest count is not yet reached.
-- Only allow inserts for guests for a contact that was created by oneself.
-- Do not allow inserts for guests for a contact referring a blocked account.
CREATE POLICY guest_insert ON vibetype.guest FOR INSERT WITH CHECK (
    event_id IN (SELECT vibetype.events_organized())
  AND
  (
    vibetype.event_guest_count_maximum(event_id) IS NULL
    OR
    vibetype.event_guest_count_maximum(event_id) > vibetype.guest_count(event_id)
  )
  AND
    contact_id IN (
      SELECT id
      FROM vibetype.contact
      WHERE created_by = vibetype.invoker_account_id()

      EXCEPT

      SELECT c.id
      FROM vibetype.contact c
        JOIN vibetype.account_block b
        ON
          c.account_id = b.blocked_account_id
          AND
          c.created_by = b.created_by
      WHERE
        c.created_by = vibetype.invoker_account_id()
    )
);

-- Only allow updates to guests accessible through guest claims.
-- Only allow updates to guests accessible through the account, but not guests auhored by a blocked account.
-- Only allow updates to guests to events organized by oneself, but not guests referencing a blocked account or authored by a blocked account.
CREATE POLICY guest_update ON vibetype.guest FOR UPDATE USING (
    id = ANY (vibetype.guest_claim_array())
  OR
  (
    contact_id IN (
      SELECT id
      FROM vibetype.contact
      WHERE account_id = vibetype.invoker_account_id()

    EXCEPT

    SELECT c.id
    FROM vibetype.contact c
      JOIN vibetype.account_block b ON c.account_id = b.created_by and c.created_by = b.blocked_account_id
    WHERE c.account_id = vibetype.invoker_account_id()
    )
  )
  OR
  (
    event_id IN (SELECT vibetype.events_organized())
    AND
    -- omit contacts created by a blocked account or referring to a blocked account
    contact_id IN (
      SELECT c.id
      FROM vibetype.contact c
      WHERE c.account_id IS NULL
      OR c.account_id NOT IN (
        SELECT id FROM vibetype_private.account_block_ids()
      )
    )
  )
);

-- Only allow deletes for guests of events organized by oneself.
CREATE POLICY guest_delete ON vibetype.guest FOR DELETE USING (
  event_id IN (SELECT vibetype.events_organized())
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
      (
        vibetype.invoker_account_id() IS NOT NULL
        AND
        OLD.contact_id IN (
          SELECT id
          FROM vibetype.contact
          WHERE contact.account_id = vibetype.invoker_account_id()
        )
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
END $$ LANGUAGE PLPGSQL STRICT VOLATILE SECURITY INVOKER;

COMMENT ON FUNCTION vibetype.trigger_guest_update() IS 'Checks if the caller has permissions to alter the desired columns.';

GRANT EXECUTE ON FUNCTION vibetype.trigger_guest_update() TO vibetype_account, vibetype_anonymous;

CREATE TRIGGER vibetype_guest_update
  BEFORE UPDATE
  ON vibetype.guest
  FOR EACH ROW
  EXECUTE PROCEDURE vibetype.trigger_guest_update();

COMMIT;
