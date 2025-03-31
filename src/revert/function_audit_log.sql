BEGIN;

DROP FUNCTION vibetype_private.trigger_audit_log();
DROP FUNCTION vibetype_private.trigger_audit_log_create_multiple();
DROP FUNCTION vibetype_private.trigger_audit_log_create(TEXT,TEXT);
DROP FUNCTION vibetype_private.trigger_audit_log_drop_multiple();
DROP FUNCTION vibetype_private.trigger_audit_log_drop(TEXT,TEXT);
DROP FUNCTION vibetype_private.trigger_audit_log_enable_multiple();
DROP FUNCTION vibetype_private.trigger_audit_log_enable(TEXT,TEXT);
DROP FUNCTION vibetype_private.trigger_audit_log_disable_multiple();
DROP FUNCTION vibetype_private.trigger_audit_log_disable(TEXT,TEXT);
DROP FUNCTION vibetype_private.adjust_audit_log_id_seq();

COMMIT;
