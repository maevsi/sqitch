BEGIN;

GRANT SELECT, INSERT, DELETE ON TABLE vibetype.account_preference_event_category TO vibetype_account;

ALTER TABLE vibetype.account_preference_event_category ENABLE ROW LEVEL SECURITY;

-- Only allow selects by the current account.
CREATE POLICY account_preference_event_category_select ON vibetype.account_preference_event_category FOR SELECT USING (
  account_id = vibetype.invoker_account_id()
);

-- Only allow inserts by the current account.
CREATE POLICY account_preference_event_category_insert ON vibetype.account_preference_event_category FOR INSERT WITH CHECK (
  account_id = vibetype.invoker_account_id()
);

-- Only allow deletes by the current account.
CREATE POLICY account_preference_event_category_delete ON vibetype.account_preference_event_category FOR DELETE USING (
  account_id = vibetype.invoker_account_id()
);

COMMIT;
