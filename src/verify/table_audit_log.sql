BEGIN;

SELECT
  id,
  schema_name,
  table_name,
  record_id,
  operation_type,
  changed_at,
  changed_by,
  old_values,
  new_values
FROM vibetype_private.audit_log
WHERE FALSE;

ROLLBACK;