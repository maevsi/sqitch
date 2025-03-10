BEGIN;

DROP POLICY account_block_select ON vibetype.account_block;
DROP POLICY account_block_insert ON vibetype.account_block;
DROP POLICY account_block_delete ON vibetype.account_block;

COMMIT;
