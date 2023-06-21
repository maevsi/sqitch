-- Revert maevsi:function_account_id_by_username from pg

BEGIN;

DROP FUNCTION maevsi.account_id_by_username;

COMMIT;
