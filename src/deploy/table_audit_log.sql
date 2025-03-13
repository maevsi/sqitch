BEGIN;

CREATE TABLE vibetype_private.audit_log (
  id          SERIAL PRIMARY KEY, -- implicitly creates the sequence vibetype_private.audit_log_id_seq
  schema_name TEXT,
  table_name  TEXT,
  record_id   TEXT,
  operation_type TEXT,
  changed_at  TIMESTAMP DEFAULT current_timestamp,
  changed_by  TEXT,
  old_values  JSONB,
  new_values  JSONB
);

COMMENT ON TABLE vibetype_private.audit_log IS E'@omit create,update,delete\nTable for storing audit log records created by trigger function vibetype_private.audit_trigger.';
COMMENT ON COLUMN vibetype_private.audit_log.id IS 'The audit log record''s internal id.';
COMMENT ON COLUMN vibetype_private.audit_log.schema_name IS 'The schema of the table which triggered this audit log record.';
COMMENT ON COLUMN vibetype_private.audit_log.table_name IS 'An operation on this table triggered this audit log record.';
COMMENT ON COLUMN vibetype_private.audit_log.record_id IS 'The id (primary key) of the table which triggered this audit log record.';
COMMENT ON COLUMN vibetype_private.audit_log.operation_type IS 'The Operation (INSERT, UPDATE, or DELETE) which triggered this audit log record.';
COMMENT ON COLUMN vibetype_private.audit_log.changed_at IS 'The timestamp when this audit log record was created.';
COMMENT ON COLUMN vibetype_private.audit_log.changed_by IS 'The user that executed the operation on the table referred to by this audit log record.';
COMMENT ON COLUMN vibetype_private.audit_log.old_values IS 'The original values of the table record before the operation, NULL if operation is INSERT.';
COMMENT ON COLUMN vibetype_private.audit_log.new_values IS 'The original values of the table record after the operation, NULL if operation is DELETE.';

COMMIT;