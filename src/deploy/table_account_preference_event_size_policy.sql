BEGIN;

GRANT SELECT, INSERT, DELETE ON TABLE maevsi.account_preference_event_size TO maevsi_account;

ALTER TABLE maevsi.account_preference_event_size ENABLE ROW LEVEL SECURITY;

-- Only allow selects by the current account.
CREATE POLICY account_preference_event_size_select ON maevsi.account_preference_event_size FOR SELECT USING (
  account_id = maevsi.invoker_account_id()
);

-- Only allow inserts by the current account.
CREATE POLICY account_preference_event_size_insert ON maevsi.account_preference_event_size FOR INSERT WITH CHECK (
  account_id = maevsi.invoker_account_id()
);

-- Only allow deletes by the current account.
CREATE POLICY account_preference_event_size_delete ON maevsi.account_preference_event_size FOR DELETE USING (
  account_id = maevsi.invoker_account_id()
);

COMMIT;
