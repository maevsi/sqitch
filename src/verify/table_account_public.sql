BEGIN;

SELECT id,
       description,
       imprint_url,
       username,
       display_name
FROM vibetype.account WHERE FALSE;

SELECT 1/COUNT(*)
FROM pg_indexes
WHERE schemaname = 'vibetype' AND indexname = 'idx_account_username_like';

SELECT 1/COUNT(*)
FROM pg_indexes
WHERE schemaname = 'vibetype' AND indexname = 'idx_account_username_lower';

ROLLBACK;
