BEGIN;

GRANT SELECT, INSERT ON vibetype.notification TO vibetype_account;

ALTER TABLE vibetype.notification ENABLE ROW LEVEL SECURITY;

CREATE POLICY notification_all ON vibetype.legal_term_acceptance FOR ALL
USING (
  account_id = vibetype.invoker_account_id()
);

COMMIT;