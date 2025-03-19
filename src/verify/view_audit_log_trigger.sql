BEGIN;

SELECT
  trigger_name,
  schema_name,
  table_name,
  trigger_enabled,
  trigger_function
FROM vibetype_private.audit_log_trigger
WHERE FALSE;

ROLLBACK;
