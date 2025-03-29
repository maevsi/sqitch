BEGIN;

SELECT
  id,
  operation_type,
  record_id,
  schema_name,
  table_name,
  values_new,
  values_old,
  created_at,
  created_by
FROM vibetype_private.audit_log
WHERE FALSE;

ROLLBACK;
