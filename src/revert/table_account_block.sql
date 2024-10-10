-- Revert maevsi:table_account_block from pg

BEGIN;

DROP TABLE maevsi.account_block;

COMMIT;
