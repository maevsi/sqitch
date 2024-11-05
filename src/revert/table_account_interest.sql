-- Revert maevsi:table_account_interest from pg

BEGIN;

DROP TABLE maevsi.account_interest;

COMMIT;
