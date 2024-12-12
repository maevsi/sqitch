BEGIN;

GRANT SELECT ON TABLE maevsi.contact TO maevsi_account, maevsi_anonymous;
GRANT INSERT, UPDATE, DELETE ON TABLE maevsi.contact TO maevsi_account;

ALTER TABLE maevsi.contact ENABLE ROW LEVEL SECURITY;

-- Only display contacts referencing the invoker's account.
-- Only display contacts authored by the invoker's account.
-- Only display contacts for which an accessible invitation exists.
CREATE POLICY contact_select ON maevsi.contact FOR SELECT USING (
  (
    maevsi.account_id() IS NOT NULL
    AND (
      account_id = maevsi.account_id()
      OR
      author_account_id = maevsi.account_id()
    )
  )
  OR
  id IN (SELECT maevsi.invitation_contact_ids())
);

-- Only allow inserts for contacts authored by the invoker's account.
CREATE POLICY contact_insert ON maevsi.contact FOR INSERT WITH CHECK (
  maevsi.account_id() IS NOT NULL
  AND
  author_account_id = maevsi.account_id()
);

-- Only allow updates for contacts authored by the invoker's account.
CREATE POLICY contact_update ON maevsi.contact FOR UPDATE USING (
  maevsi.account_id() IS NOT NULL
  AND
  author_account_id = maevsi.account_id()
);

-- Only allow deletes for contacts authored by the invoker's account except for the own account's contact.
CREATE POLICY contact_delete ON maevsi.contact FOR DELETE USING (
  maevsi.account_id() IS NOT NULL
  AND
  author_account_id = maevsi.account_id()
  AND
  account_id IS DISTINCT FROM maevsi.account_id()
);

COMMIT;
