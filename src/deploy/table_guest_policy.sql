BEGIN;

GRANT SELECT, UPDATE ON TABLE maevsi.guest TO maevsi_account, maevsi_anonymous;
GRANT INSERT, DELETE ON TABLE maevsi.guest TO maevsi_account;

ALTER TABLE maevsi.guest ENABLE ROW LEVEL SECURITY;

CREATE POLICY guest_select ON maevsi.guest FOR SELECT USING (
    -- Display guests accessible through guest claims.
    id = ANY (maevsi.guest_claim_array())
  OR
  (
    -- Display guests where the contact is the invoker account.
    contact_id IN (
      SELECT id
      FROM maevsi.contact
      WHERE account_id = maevsi.invoker_account_id()
        -- omit contacts created by a user who is blocked by the invoker
        -- omit contacts created by a user who blocked the invoker.
        AND created_by NOT IN (
          SELECT id FROM maevsi_private.account_block_ids()
        )
    )
  )
  OR
  (
    -- Display guests to events organized by the invoker,
    -- but omit guests with contacts pointing at a user blocked by the invoker or pointing at a user who blocked the invoker.
    -- Also omit guests created by a user blocked by the invoker or created by a user who blocked the invoker.
    event_id IN (SELECT maevsi.events_organized())
    AND
      contact_id IN (
        SELECT c.id
        FROM maevsi.contact c
        WHERE
          (
            c.account_id IS NULL
            OR
            c.account_id NOT IN (
              SELECT id FROM maevsi_private.account_block_ids()
            )
          )
          AND
          c.created_by NOT IN (
            SELECT id FROM maevsi_private.account_block_ids()
          )
      )
  )
);

-- Only allow inserts for guests of events organized by oneself.
-- Only allow inserts for guests of events for which the maximum guest count is not yet reached.
-- Only allow inserts for guests for a contact that was created by oneself.
-- Do not allow inserts for guests for a contact referring a blocked account.
CREATE POLICY guest_insert ON maevsi.guest FOR INSERT WITH CHECK (
    event_id IN (SELECT maevsi.events_organized())
  AND
  (
    maevsi.event_guest_count_maximum(event_id) IS NULL
    OR
    maevsi.event_guest_count_maximum(event_id) > maevsi.guest_count(event_id)
  )
  AND
    contact_id IN (
      SELECT id
      FROM maevsi.contact
      WHERE created_by = maevsi.invoker_account_id()

      EXCEPT

      SELECT c.id
      FROM maevsi.contact c
        JOIN maevsi.account_block b
        ON
          c.account_id = b.blocked_account_id
          AND
          c.created_by = b.created_by
      WHERE
        c.created_by = maevsi.invoker_account_id()
    )
);

-- Only allow updates to guests accessible through guest claims.
-- Only allow updates to guests accessible through the account, but not guests auhored by a blocked account.
-- Only allow updates to guests to events organized by oneself, but not guests referencing a blocked account or authored by a blocked account.
CREATE POLICY guest_update ON maevsi.guest FOR UPDATE USING (
    id = ANY (maevsi.guest_claim_array())
  OR
  (
    contact_id IN (
      SELECT id
      FROM maevsi.contact
      WHERE account_id = maevsi.invoker_account_id()

      EXCEPT

      SELECT c.id
      FROM maevsi.contact c
        JOIN maevsi.account_block b ON c.account_id = b.created_by and c.created_by = b.blocked_account_id
      WHERE c.account_id = maevsi.invoker_account_id()
    )
  )
  OR
  (
    event_id IN (SELECT maevsi.events_organized())
    AND
    -- omit contacts created by a blocked account or referring to a blocked account
    contact_id IN (
      SELECT c.id
      FROM maevsi.contact c
      WHERE
        c.created_by NOT IN (
          SELECT id FROM maevsi_private.account_block_ids()
        )
        AND
        (
          c.account_id IS NULL
          OR
          c.account_id NOT IN (
            SELECT id FROM maevsi_private.account_block_ids()
          )
        )
    )
  )
);

-- Only allow deletes for guests of events organized by oneself.
CREATE POLICY guest_delete ON maevsi.guest FOR DELETE USING (
  event_id IN (SELECT maevsi.events_organized())
);

CREATE FUNCTION maevsi.trigger_guest_update() RETURNS TRIGGER AS $$
DECLARE
  whitelisted_cols TEXT[] := ARRAY['feedback', 'feedback_paper'];
BEGIN
  IF
      TG_OP = 'UPDATE'
    AND ( -- Invited.
      OLD.id = ANY (maevsi.guest_claim_array())
      OR
      (
        maevsi.invoker_account_id() IS NOT NULL
        AND
        OLD.contact_id IN (
          SELECT id
          FROM maevsi.contact
          WHERE contact.account_id = maevsi.invoker_account_id()
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
    NEW.updated_by = maevsi.invoker_account_id();
    RETURN NEW;
  END IF;
END $$ LANGUAGE PLPGSQL STRICT VOLATILE SECURITY INVOKER;

COMMENT ON FUNCTION maevsi.trigger_guest_update() IS 'Checks if the caller has permissions to alter the desired columns.';

GRANT EXECUTE ON FUNCTION maevsi.trigger_guest_update() TO maevsi_account, maevsi_anonymous;

CREATE TRIGGER maevsi_guest_update
  BEFORE UPDATE
  ON maevsi.guest
  FOR EACH ROW
  EXECUTE PROCEDURE maevsi.trigger_guest_update();

COMMIT;
