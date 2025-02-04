BEGIN;

DROP POLICY account_block_delete ON maevsi.account_block;
DROP POLICY account_block_insert ON maevsi.account_block;
DROP POLICY account_block_select ON maevsi.account_block;

COMMIT;
