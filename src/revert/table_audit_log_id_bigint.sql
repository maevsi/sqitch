BEGIN;

CREATE OR REPLACE FUNCTION vibetype_private.adjust_audit_log_id_seq ()
RETURNS void AS $$
DECLARE
  _value_max INTEGER;
BEGIN
  SELECT MAX(id) INTO _value_max
    FROM vibetype_private.audit_log;

  PERFORM setval(
    'vibetype_private.audit_log_id_seq',
    CASE WHEN _value_max IS NOT NULL THEN _value_max + 1 ELSE 1 END,
    false
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

ALTER SEQUENCE vibetype_private.audit_log_id_seq AS INTEGER;
ALTER TABLE vibetype_private.audit_log ALTER COLUMN id TYPE INTEGER;

COMMIT;
