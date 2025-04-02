BEGIN;

GRANT SELECT, INSERT ON vibetype.notification TO vibetype_account;

ALTER TABLE vibetype.notification ENABLE ROW LEVEL SECURITY;

CREATE POLICY notification_select ON vibetype.notification FOR SELECT USING (
  created_by = vibetype.invoker_account_id()
);

CREATE POLICY notification_insert ON vibetype.notification FOR INSERT WITH CHECK (
  created_by = vibetype.invoker_account_id()
);

COMMIT;