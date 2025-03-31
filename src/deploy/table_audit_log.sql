BEGIN;

CREATE TABLE vibetype_private.audit_log (
  id              SERIAL PRIMARY KEY, -- implicitly creates the sequence vibetype_private.audit_log_id_seq

  operation_type  TEXT NOT NULL,
  record_id       TEXT NOT NULL,
  schema_name     TEXT NOT NULL,
  table_name      TEXT NOT NULL,
  values_new      JSONB,
  values_old      JSONB,

  created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by      TEXT NOT NULL
);

COMMENT ON TABLE vibetype_private.audit_log IS 'Table for storing audit log records.';
COMMENT ON COLUMN vibetype_private.audit_log.id IS 'The audit log record''s internal id.';
COMMENT ON COLUMN vibetype_private.audit_log.operation_type IS 'The operation which triggered the audit log record. Can be `INSERT`, `UPDATE`, or `DELETE`.';
COMMENT ON COLUMN vibetype_private.audit_log.record_id IS 'The primary key of the table record which triggered the audit log record.';
COMMENT ON COLUMN vibetype_private.audit_log.schema_name IS 'The schema of the table which triggered this audit log record.';
COMMENT ON COLUMN vibetype_private.audit_log.table_name IS 'The operation on a table that triggered the audit log record.';
COMMENT ON COLUMN vibetype_private.audit_log.values_new IS 'The original values of the table record after the operation, `NULL` if operation is `DELETE`.';
COMMENT ON COLUMN vibetype_private.audit_log.values_old IS 'The original values of the table record before the operation, `NULL` if operation is `INSERT`.';
COMMENT ON COLUMN vibetype_private.audit_log.created_at IS 'The timestamp of when the audit log record was created.';
COMMENT ON COLUMN vibetype_private.audit_log.created_by IS 'The user that executed the operation on the table referred to by this audit log record.';

COMMIT;
