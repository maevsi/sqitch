BEGIN;

SELECT 1/COUNT(*)
FROM   pg_class c
JOIN   pg_namespace n ON n.oid = c.relnamespace
WHERE  c.relname = 'idx_guest_contact_id'
AND    n.nspname = 'vibetype';

ROLLBACK;
