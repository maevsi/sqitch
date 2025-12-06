BEGIN;

SELECT id,
       description,
       imprint,
       username
FROM vibetype.account WHERE FALSE;

SELECT 1/COUNT(*)
FROM pg_indexes
WHERE schemaname = 'vibetype' AND indexname = 'idx_account_username_like';

ROLLBACK;
