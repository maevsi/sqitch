BEGIN;

COMMENT ON TABLE vibetype.account IS E'@omit create,delete\nPublic account data.';
COMMENT ON COLUMN vibetype.account.id IS E'@omit create,update\nThe account''s internal id.';
COMMENT ON COLUMN vibetype.account.username IS E'@omit update\nThe account''s username.';

GRANT UPDATE ON TABLE vibetype.account TO vibetype_account;

CREATE POLICY account_update ON vibetype.account FOR UPDATE
USING (
  id = vibetype.invoker_account_id()
);

COMMIT;
