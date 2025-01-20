BEGIN;

GRANT SELECT ON TABLE maevsi.contact TO maevsi_account, maevsi_anonymous;
GRANT INSERT, UPDATE, DELETE ON TABLE maevsi.contact TO maevsi_account;

ALTER TABLE maevsi.contact ENABLE ROW LEVEL SECURITY;

-- Only display contacts referencing the invoker's account, omit contacts authored by a blocked account.
-- Only display contacts authored by the invoker's account, omit contacts referring to a blocked account.
-- Only display contacts for which an accessible guest exists.
CREATE POLICY contact_select ON maevsi.contact FOR SELECT USING (
  (
    account_id = maevsi.invoker_account_id()
    AND
    author_account_id NOT IN (
      SELECT blocked_account_id
      FROM maevsi.account_block
      WHERE author_account_id = maevsi.invoker_account_id()
      UNION ALL
      SELECT author_account_id
      FROM maevsi.account_block
      WHERE blocked_account_id = maevsi.invoker_account_id()
    )
  )
  OR
  (
    author_account_id = maevsi.invoker_account_id()
    AND
    (
      account_id IS NULL
      OR
      account_id NOT IN (
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
  OR id IN (SELECT maevsi.guest_contact_ids())
);

-- Only allow inserts for contacts authored by the invoker's account.
-- Disallow inserts for contacts that refer to a blocked account.
CREATE POLICY contact_insert ON maevsi.contact FOR INSERT WITH CHECK (
  author_account_id = maevsi.invoker_account_id()
  AND account_id NOT IN (
    SELECT blocked_account_id
    FROM maevsi.account_block
    WHERE author_account_id = maevsi.invoker_account_id()
  )
);

-- Only allow updates for contacts authored by the invoker's account.
-- No contact referring to a blocked account can be updated.
CREATE POLICY contact_update ON maevsi.contact FOR UPDATE USING (
  author_account_id = maevsi.invoker_account_id()
  AND account_id NOT IN (
    SELECT blocked_account_id
    FROM maevsi.account_block
    WHERE author_account_id = maevsi.invoker_account_id()
  )
);

-- Only allow deletes for contacts authored by the invoker's account except for the own account's contact.
CREATE POLICY contact_delete ON maevsi.contact FOR DELETE USING (
  maevsi.invoker_account_id() IS NOT NULL
  AND
  author_account_id = maevsi.invoker_account_id()
  AND
  account_id IS DISTINCT FROM maevsi.invoker_account_id()
);

COMMIT;
