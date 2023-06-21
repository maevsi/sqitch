-- Revert maevsi:function_account_username_by_id from pg

BEGIN;

DROP FUNCTION maevsi.account_username_by_id;

COMMIT;
