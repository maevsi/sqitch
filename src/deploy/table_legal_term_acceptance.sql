BEGIN;

CREATE TABLE maevsi.legal_term_acceptance (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  account_id    UUID NOT NULL REFERENCES maevsi.account(id) ON DELETE CASCADE,
  legal_term_id UUID NOT NULL REFERENCES maevsi.legal_term(id) ON DELETE RESTRICT, -- deletion of the parent row should not be possible

  created_at    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE maevsi.legal_term_acceptance IS '@omit update,delete\nTracks each user account''s acceptance of legal terms and conditions.';
COMMENT ON COLUMN maevsi.legal_term_acceptance.id IS E'@omit create\nUnique identifier for this legal term acceptance record. Automatically generated for each new acceptance.';
COMMENT ON COLUMN maevsi.legal_term_acceptance.account_id IS 'The user account ID that accepted the legal terms. If the account is deleted, this acceptance record will also be deleted.';
COMMENT ON COLUMN maevsi.legal_term_acceptance.legal_term_id IS 'The ID of the legal terms that were accepted. Deletion of these legal terms is restricted while they are still referenced in this table.';
COMMENT ON COLUMN maevsi.legal_term_acceptance.created_at IS E'@omit create\nTimestamp showing when the legal terms were accepted, set automatically at the time of acceptance.';

GRANT SELECT, INSERT ON TABLE maevsi.legal_term_acceptance TO maevsi_account;

ALTER TABLE maevsi.legal_term_acceptance ENABLE ROW LEVEL SECURITY;

-- Allow to select legal term acceptances for the own account.
CREATE POLICY legal_term_acceptance_select ON maevsi.legal_term_acceptance FOR SELECT USING (
  maevsi.invoker_account_id() IS NOT NULL
  AND
  account_id = maevsi.invoker_account_id()
);

CREATE POLICY legal_term_acceptance_insert ON maevsi.legal_term_acceptance FOR INSERT WITH CHECK (
  maevsi.invoker_account_id() IS NOT NULL
  AND
  account_id = maevsi.invoker_account_id()
);

COMMIT;
