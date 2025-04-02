BEGIN;

CREATE VIEW vibetype_private.audit_log_trigger (
  trigger_name, schema_name, table_name, trigger_enabled, trigger_function
) AS
SELECT t.tgname, n.nspname, c.relname, t.tgenabled, p.proname
FROM pg_catalog.pg_trigger t
  JOIN pg_catalog.pg_class c ON t.tgrelid = c.oid
  JOIN pg_catalog.pg_namespace n on c.relnamespace = n.oid
  JOIN pg_catalog.pg_proc p ON t.tgfoid = p.oid
WHERE t.tgname = 'z_indexed_audit_log_trigger'
  AND n.nspname in ('vibetype', 'vibetype_private');

COMMENT ON VIEW vibetype_private.audit_log_trigger IS 'View showing all triggers named `z_indexed_audit_log_trigger` on tables in the `vibetype` or `vibetype_private` schema.';
COMMENT ON COLUMN vibetype_private.audit_log_trigger.trigger_name IS 'The name of the trigger, should be `z_indexed_audit_log_trigger`';
COMMENT ON COLUMN vibetype_private.audit_log_trigger.schema_name IS 'The schema of the table for which this trigger was created.';
COMMENT ON COLUMN vibetype_private.audit_log_trigger.table_name IS 'The table for which this trigger was created.';
COMMENT ON COLUMN vibetype_private.audit_log_trigger.trigger_enabled IS 'A character indicating whether the trigger is enabled (`trigger_enabled != ''D''`) or disabled (`trigger_enabled = ''D''`).';
COMMENT ON COLUMN vibetype_private.audit_log_trigger.trigger_function IS 'The name of the function associated with the trigger.';

COMMIT;
