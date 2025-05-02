BEGIN;

DROP POLICY account_block_all ON vibetype.account_block;

DROP TABLE vibetype.account_block;

COMMIT;
