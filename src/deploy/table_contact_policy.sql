-- Deploy maevsi:table_contact_policy to pg
-- requires: schema_public
-- requires: table_account_block
-- requires: table_contact
-- requires: role_account
-- requires: role_anonymous
-- requires: function_invitation_contact_ids

BEGIN;

GRANT SELECT ON TABLE maevsi.contact TO maevsi_account, maevsi_anonymous;
GRANT INSERT, UPDATE, DELETE ON TABLE maevsi.contact TO maevsi_account;

ALTER TABLE maevsi.contact ENABLE ROW LEVEL SECURITY;

-- Only display contacts referencing the invoker's account, omit contacts authored by a blocked account.
-- Only display contacts authored by the invoker's account, omit contacts referring to a blocked account.
-- Only display contacts for which an accessible invitation exists.
CREATE POLICY contact_select ON maevsi.contact FOR SELECT USING (
  (
    account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
    AND
    author_account_id NOT IN (
      SELECT blocked_account_id
      FROM maevsi.account_block
      WHERE author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
      UNION ALL
      SELECT author_account_id
      FROM maevsi.account_block
      WHERE blocked_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
    )
  )
  OR
  (
    author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
    AND
    (
      account_id IS NULL
      OR
      account_id NOT IN (
        SELECT blocked_account_id
        FROM maevsi.account_block
        WHERE author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
        UNION ALL
        SELECT author_account_id
        FROM maevsi.account_block
        WHERE blocked_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
      )
    )
  )
  OR id IN (SELECT maevsi.invitation_contact_ids())
);

-- Only allow inserts for contacts authored by the invoker's account.
-- Disallow inserts for contacts that refer to a blocked account.
CREATE POLICY contact_insert ON maevsi.contact FOR INSERT WITH CHECK (
  author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
  AND account_id NOT IN (
    SELECT blocked_account_id
    FROM maevsi.account_block
    WHERE author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
  )
);

-- Only allow updates for contacts authored by the invoker's account.
-- No contact referring to a blocked account can be updated.
CREATE POLICY contact_update ON maevsi.contact FOR UPDATE USING (
  author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
  AND account_id NOT IN (
    SELECT blocked_account_id
    FROM maevsi.account_block
    WHERE author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
  )
);

-- Only allow deletes for contacts authored by the invoker's account except for the own account's contact.
CREATE POLICY contact_delete ON maevsi.contact FOR DELETE USING (
  NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NOT NULL
  AND
  author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
  AND
  account_id IS DISTINCT FROM NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

COMMIT;
