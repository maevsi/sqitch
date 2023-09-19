-- Revert maevsi:table_account_public from pg

BEGIN;

DROP TABLE maevsi.account;

COMMIT;
