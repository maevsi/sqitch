BEGIN;

SELECT 1/count(*) FROM pg_indexes WHERE schemaname = 'vibetype' AND indexname = 'idx_account_username_lower';

ROLLBACK;
