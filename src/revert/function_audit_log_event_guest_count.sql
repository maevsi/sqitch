BEGIN;

CREATE OR REPLACE FUNCTION vibetype_private.trigger_audit_log() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
DECLARE
  _account_id UUID;
  _data_new JSONB;
  _data_old JSONB;
  _key TEXT;
  _user_name TEXT;
  _values_new JSONB;
  _values_old JSONB;
BEGIN
  _account_id := NULLIF(current_setting('jwt.claims.sub', true), '')::UUID;

  IF _account_id IS NULL THEN
    _user_name := current_user;
  ELSE
    SELECT username INTO _user_name
      FROM vibetype.account
      WHERE id = _account_id;
  END IF;

  _values_new := '{}';
  _values_old := '{}';

  IF TG_OP = 'INSERT' THEN
    _data_new := to_jsonb(NEW);
    _values_new := _data_new;

  ELSIF TG_OP = 'UPDATE' THEN
    _data_new := to_jsonb(NEW);
    _data_old := to_jsonb(OLD);

    FOR _key IN SELECT jsonb_object_keys(_data_new) INTERSECT SELECT jsonb_object_keys(_data_old)
    LOOP
      IF _data_new ->> _key != _data_old ->> _key THEN
        _values_new := _values_new || jsonb_build_object(_key, _data_new ->> _key);
        _values_old := _values_old || jsonb_build_object(_key, _data_old ->> _key);
      END IF;
    END LOOP;

  ELSIF TG_OP = 'DELETE' THEN
    _data_old := to_jsonb(OLD);
    _values_old := _data_old;

    FOR _key IN SELECT jsonb_object_keys(_data_old)
    LOOP
      _values_old := _values_old || jsonb_build_object(_key, _data_old ->> _key);
    END LOOP;

  END IF;

  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    INSERT INTO vibetype_private.audit_log (schema_name, table_name, record_id, operation_type, created_by, values_old, values_new)
      VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, NEW.id, TG_OP, _user_name, _values_old, _values_new);

    RETURN NEW;
  ELSE
    INSERT INTO vibetype_private.audit_log (schema_name, table_name, record_id, operation_type, created_by, values_old, values_new)
      VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, OLD.id, TG_OP, _user_name, _values_old, _values_new);

    RETURN OLD;
  END IF;
END;
$$;

COMMIT;
