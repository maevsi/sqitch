BEGIN;

-- drop all audit log_triggers, otherwise function can possibly not be dropped
SELECT vibetype_private.drop_audit_log_triggers();

DROP FUNCTION vibetype_private.trigger_audit_log();
DROP FUNCTION vibetype_private.create_audit_log_triggers();
DROP FUNCTION vibetype_private.create_audit_log_trigger_for_table(TEXT,TEXT);
DROP FUNCTION vibetype_private.drop_audit_log_triggers();
DROP FUNCTION vibetype_private.drop_audit_log_trigger_for_table(TEXT,TEXT);
DROP FUNCTION vibetype_private.enable_audit_log_triggers();
DROP FUNCTION vibetype_private.enable_audit_log_trigger_for_table(TEXT,TEXT);
DROP FUNCTION vibetype_private.disable_audit_log_triggers();
DROP FUNCTION vibetype_private.disable_audit_log_trigger_for_table(TEXT,TEXT);
DROP FUNCTION vibetype_private.adjust_audit_log_id_seq();

COMMIT;