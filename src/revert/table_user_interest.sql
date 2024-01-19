-- Revert maevsi:table_user_interest from pg

BEGIN;

DROP TABLE maevsi.table_user_interest;

COMMIT;
