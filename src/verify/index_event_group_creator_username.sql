BEGIN;

SELECT 1/COUNT(*)
FROM   pg_class c
JOIN   pg_namespace n ON n.oid = c.relnamespace
WHERE  c.relname = 'idx_event_group_created_by'
AND    n.nspname = 'vibetype';

ROLLBACK;
