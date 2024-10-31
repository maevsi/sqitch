-- Deploy maevsi:table_account_event_size_pref_policy to pg

BEGIN;

GRANT SELECT, INSERT, DELETE ON TABLE maevsi.account_event_size_pref TO maevsi_account;

ALTER TABLE maevsi.account_event_size_pref ENABLE ROW LEVEL SECURITY;

-- Only allow selects by the current account.
CREATE POLICY account_event_size_pref_select ON maevsi.account_event_size_pref FOR SELECT USING (
  account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

-- Only allow inserts by the current account.
CREATE POLICY account_event_size_pref_insert ON maevsi.account_event_size_pref FOR INSERT WITH CHECK (
  account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

-- Only allow deletes by the current account.
CREATE POLICY account_event_size_pref_delete ON maevsi.account_event_size_pref FOR DELETE USING (
  account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

COMMIT;
