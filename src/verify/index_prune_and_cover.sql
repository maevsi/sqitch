BEGIN;

SELECT 1/count(*) FROM pg_indexes WHERE schemaname = 'vibetype' AND indexname = 'idx_event_created_by_start';
SELECT 1/count(*) FROM pg_indexes WHERE schemaname = 'vibetype_private' AND indexname = 'idx_account_email_address_verification';
SELECT 1/count(*) FROM pg_indexes WHERE schemaname = 'vibetype_private' AND indexname = 'idx_account_password_reset_verification';

ROLLBACK;
