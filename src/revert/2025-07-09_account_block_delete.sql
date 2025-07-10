BEGIN;

REVOKE DELETE ON TABLE vibetype.account_block FROM vibetype_account;

COMMIT;
