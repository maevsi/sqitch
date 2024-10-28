-- Revert maevsi:table_account_block_policy from pg

BEGIN;

DROP POLICY account_block_insert ON maevsi.account_block;
DROP POLICY account_block_select ON maevsi.account_block;

COMMIT;
