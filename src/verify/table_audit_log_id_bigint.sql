BEGIN;

SELECT id
FROM vibetype_private.audit_log
WHERE FALSE;

ROLLBACK;
