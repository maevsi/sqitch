BEGIN;

GRANT SELECT, UPDATE ON TABLE maevsi.invitation TO maevsi_account, maevsi_anonymous;
GRANT INSERT, DELETE ON TABLE maevsi.invitation TO maevsi_account;

ALTER TABLE maevsi.invitation ENABLE ROW LEVEL SECURITY;

-- Only display invitations issued to oneself through invitation claims.
-- Only display invitations issued to oneself through the account, omit invitations authored by a blocked user.
-- Only display invitations to events organized by oneself, omit invitations authored by a blocked user and invitations issued for a blocked user.
CREATE POLICY invitation_select ON maevsi.invitation FOR SELECT USING (
    id = ANY (maevsi.invitation_claim_array())
  OR
  (
    contact_id IN (
      SELECT id
      FROM maevsi.contact
      WHERE account_id = maevsi.invoker_account_id()

      EXCEPT

      -- contacts to oneself authored by a blocked account
      SELECT c.id
      FROM maevsi.contact c
        JOIN maevsi.account_block b
        ON
          c.account_id = b.author_account_id
          AND
          c.author_account_id = b.blocked_account_id
      WHERE
        c.account_id = maevsi.invoker_account_id()
    )
  )
  OR
  (
      event_id IN (SELECT maevsi.events_organized())
    AND
      contact_id IN (
        SELECT c.id
        FROM maevsi.contact c
        WHERE
            c.account_id IS NULL
          OR
            c.account_id NOT IN (
              SELECT blocked_account_id
              FROM maevsi.account_block
              WHERE author_account_id = maevsi.invoker_account_id()
              UNION ALL
              SELECT author_account_id
              FROM maevsi.account_block
              WHERE blocked_account_id = maevsi.invoker_account_id()
            )
      )
  )
);

-- Only allow inserts for invitations to events organized by oneself.
-- Only allow inserts for invitations to events for which the maximum invitee count is not yet reached.
-- Only allow inserts for invitations issued to a contact that was created by oneself.
-- Do not allow inserts for invitations issued to a contact referring a blocked account.
CREATE POLICY invitation_insert ON maevsi.invitation FOR INSERT WITH CHECK (
    event_id IN (SELECT maevsi.events_organized())
  AND
  (
    maevsi.event_invitee_count_maximum(event_id) IS NULL
    OR
    maevsi.event_invitee_count_maximum(event_id) > maevsi.invitee_count(event_id)
  )
  AND
    contact_id IN (
      SELECT id
      FROM maevsi.contact
      WHERE author_account_id = maevsi.invoker_account_id()

      EXCEPT

      SELECT c.id
      FROM maevsi.contact c
        JOIN maevsi.account_block b
        ON
          c.account_id = b.blocked_account_id
          AND
          c.author_account_id = b.author_account_id
      WHERE
        c.author_account_id = maevsi.invoker_account_id()
    )
);

-- Only allow updates to invitations issued to oneself through invitation claims.
-- Only allow updates to invitations issued to oneself through the account, but not invitations auhored by a blocked account.
-- Only allow updates to invitations to events organized by oneself, but not invitations issued to a blocked account or issued by a blocked account.
CREATE POLICY invitation_update ON maevsi.invitation FOR UPDATE USING (
    id = ANY (maevsi.invitation_claim_array())
  OR
  (
    contact_id IN (
      SELECT id
      FROM maevsi.contact
      WHERE account_id = maevsi.invoker_account_id()

    EXCEPT

    SELECT c.id
    FROM maevsi.contact c
      JOIN maevsi.account_block b ON c.account_id = b.author_account_id and c.author_account_id = b.blocked_account_id
    WHERE c.account_id = maevsi.invoker_account_id()
    )
  )
  OR
  (
    event_id IN (SELECT maevsi.events_organized())
    AND
    -- omit contacts authored by a blocked account or referring to a blocked account
    contact_id IN (
      SELECT c.id
      FROM maevsi.contact c
      WHERE c.account_id IS NULL
      OR c.account_id NOT IN (
        SELECT blocked_account_id
        FROM maevsi.account_block
        WHERE author_account_id = maevsi.invoker_account_id()
        UNION ALL
        SELECT author_account_id
        FROM maevsi.account_block
        WHERE blocked_account_id = maevsi.invoker_account_id()
      )
    )
  )
);

-- Only allow deletes for invitations to events organized by oneself.
CREATE POLICY invitation_delete ON maevsi.invitation FOR DELETE USING (
  event_id IN (SELECT maevsi.events_organized())
);

CREATE FUNCTION maevsi.trigger_invitation_update() RETURNS TRIGGER AS $$
DECLARE
  whitelisted_cols TEXT[] := ARRAY['feedback', 'feedback_paper'];
BEGIN
  IF
      TG_OP = 'UPDATE'
    AND ( -- Invited.
      OLD.id = ANY (maevsi.invitation_claim_array())
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

COMMENT ON FUNCTION maevsi.trigger_invitation_update() IS 'Checks if the caller has permissions to alter the desired columns.';

GRANT EXECUTE ON FUNCTION maevsi.trigger_invitation_update() TO maevsi_account, maevsi_anonymous;

CREATE TRIGGER maevsi_invitation_update
  BEFORE UPDATE
  ON maevsi.invitation
  FOR EACH ROW
  EXECUTE PROCEDURE maevsi.trigger_invitation_update();

COMMIT;
