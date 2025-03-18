BEGIN;

SELECT 1/COUNT(*)
FROM   pg_class c
JOIN   pg_namespace n ON n.oid = c.relnamespace
WHERE  c.relname = 'idx_account_private_location'
AND    n.nspname = 'vibetype_private';

ROLLBACK;
