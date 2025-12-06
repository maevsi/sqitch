BEGIN;

GRANT SELECT ON TABLE vibetype.contact TO vibetype_anonymous;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE vibetype.contact TO vibetype_account;

ALTER TABLE vibetype.contact ENABLE ROW LEVEL SECURITY;

-- 1) Display contacts referencing the invoker's account, omit contacts created by an account
--  blocked by the invoker or by an account that blocked the invoker.
-- 2) Display contacts created by the invoker's account, omit contacts referring to an account
--    blocked by the invoker or by an account that blocked the invoker.
-- 3) Display contacts for which an accessible guest exists.
CREATE POLICY contact_select ON vibetype.contact FOR SELECT
USING (
  (
    contact.account_id = vibetype.invoker_account_id()
    AND
    NOT EXISTS (
      SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = contact.created_by
    )
  )
  OR
  (
    contact.created_by = vibetype.invoker_account_id()
    AND
    NOT EXISTS (
      SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = contact.account_id
    )
  )
  OR EXISTS (
    SELECT 1
    FROM vibetype.guest_contact_ids() gci(contact_id)
    WHERE gci.contact_id = contact.id
  )
);

-- Only allow inserts for contacts created by the invoker's account.
-- Disallow inserts for contacts that refer to a blocked account.
CREATE POLICY contact_insert ON vibetype.contact FOR INSERT
WITH CHECK (
  contact.created_by = vibetype.invoker_account_id()
  AND NOT EXISTS (
    SELECT 1
    FROM vibetype.account_block b
    WHERE b.created_by = vibetype.invoker_account_id()
      AND b.blocked_account_id = contact.account_id
  )
);

-- Only allow updates for contacts created by the invoker's account.
-- No contact referring to a blocked account can be updated.
CREATE POLICY contact_update ON vibetype.contact FOR UPDATE
USING (
  contact.created_by = vibetype.invoker_account_id()
  AND NOT EXISTS (
    SELECT 1
    FROM vibetype.account_block b
    WHERE b.created_by = vibetype.invoker_account_id()
      AND b.blocked_account_id = contact.account_id
  )
);

-- Only allow deletes for contacts created by the invoker's account except for the own account's contact.
CREATE POLICY contact_delete ON vibetype.contact FOR DELETE
USING (
  created_by = vibetype.invoker_account_id()
  AND
  account_id IS DISTINCT FROM vibetype.invoker_account_id()
);

COMMIT;
