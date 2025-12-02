BEGIN;

CREATE FUNCTION vibetype_private.trigger_audit_log() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
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
  _account_id := NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID;

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
    INSERT INTO vibetype_private.audit_log (schema_name, table_name, record_id, operation_type, created_by, values_old, _alues_new)
      VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, OLD.id, TG_OP, _user_name, _values_old, _values_new);

    RETURN OLD;
  END IF;
END;
$$;

COMMENT ON FUNCTION vibetype_private.trigger_audit_log() IS 'Generic audit trigger function creating records in table vibetype_private.audit_log.
inspired by https://medium.com/israeli-tech-radar/postgresql-trigger-based-audit-log-fd9d9d5e412c';


CREATE FUNCTION vibetype_private.trigger_audit_log_create_multiple() -- create all audit log triggers for all tables
RETURNS void AS $$
DECLARE
  _record RECORD;
  _trigger_name TEXT := 'z_indexed_audit_log_trigger'; -- PostgreSql Documentation, section 37.1: If more than one trigger is defined for the same event on the same relation, the triggers will be fired in alphabetical order by trigger name.
BEGIN
  FOR _record IN
    SELECT n.nspname ,c.relname
      FROM pg_catalog.pg_class c
        -- audit log triggers works only for tables having an id column
        JOIN pg_catalog.pg_attribute a ON c.oid = a.attrelid AND a.attname = 'id'
        JOIN pg_catalog.pg_namespace n ON c.relnamespace = n.oid
      WHERE c.relkind = 'r' AND n.nspname IN ('vibetype', 'vibetype_private')
        -- negative list, make sure that at least audit_log table is not audited
        AND (n.nspname, c.relname) NOT IN (
          ('vibetype_private', 'audit_log'),
          ('vibetype_private', 'jwt')
        )
  LOOP
     EXECUTE 'CREATE TRIGGER ' || _trigger_name ||
        ' BEFORE INSERT OR UPDATE OR DELETE ON ' ||
        _record.nspname || '.' || _record.relname ||
        ' FOR EACH ROW EXECUTE FUNCTION vibetype_private.trigger_audit_log()';
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.trigger_audit_log_create_multiple() IS 'Function creating all audit log triggers for all tables that should be audited.';


CREATE FUNCTION vibetype_private.trigger_audit_log_create (
  schema_name TEXT,
  table_name TEXT
) RETURNS void AS $$
DECLARE
  _trigger_name TEXT := 'z_indexed_audit_log_trigger';
BEGIN
  IF EXISTS(
    SELECT 1
      FROM pg_catalog.pg_class c
        JOIN pg_catalog.pg_attribute a ON c.oid = a.attrelid AND a.attname = 'id' -- audit log triggers works only for tables having an id column
        JOIN pg_catalog.pg_namespace n ON c.relnamespace = n.oid
      WHERE c.relkind = 'r'
        AND n.nspname = trigger_audit_log_create.schema_name
        AND c.relname = trigger_audit_log_create.table_name
        -- negative list, make sure that at least audit_log table is not audited
        AND (n.nspname, c.relname) not in (
          ('vibetype_private', 'audit_log'),
          ('vibetype_private', 'jwt')
        )
  ) THEN
    EXECUTE 'CREATE TRIGGER ' || _trigger_name ||
      ' BEFORE INSERT OR UPDATE OR DELETE ON ' ||
      trigger_audit_log_create.schema_name || '.' || trigger_audit_log_create.table_name ||
      ' FOR EACH ROW EXECUTE FUNCTION vibetype_private.trigger_audit_log()';
  ELSE
    RAISE EXCEPTION 'Table %.% cannot have an audit log trigger.',
      trigger_audit_log_create.schema_name, trigger_audit_log_create.table_name
      USING ERRCODE = 'VTALT';
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.trigger_audit_log_create(TEXT, TEXT) IS 'Function creating an audit log trigger for a single table.\n\nError codes:\n- **VTALT** when a table cannot have an audit log trigger.';


CREATE FUNCTION vibetype_private.trigger_audit_log_drop_multiple()
RETURNS void AS $$
DECLARE
  _record RECORD;
BEGIN
  FOR _record IN
    SELECT trigger_name, schema_name, table_name
      FROM vibetype_private.audit_log_trigger
  LOOP
    EXECUTE 'DROP TRIGGER ' || _record.trigger_name || ' ON ' || _record.schema_name || '.' || _record.table_name;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.trigger_audit_log_drop_multiple() IS 'Function dropping all audit log triggers for all tables that are currently audited.';


CREATE FUNCTION vibetype_private.trigger_audit_log_drop (
  schema_name TEXT,
  table_name TEXT
) RETURNS void AS $$
DECLARE
  _record RECORD;
  _i INTEGER := 0;
BEGIN
  FOR _record IN
    SELECT t.trigger_name, t.schema_name, t.table_name
      FROM vibetype_private.audit_log_trigger t
      WHERE t.schema_name = trigger_audit_log_drop.schema_name
        AND t.table_name = trigger_audit_log_drop.table_name
  LOOP
    _i := _i + 1;

    EXECUTE 'DROP TRIGGER ' || _record.trigger_name || ' ON ' ||
      _record.schema_name || '.' || _record.table_name;
  END LOOP;

  IF _i = 0 THEN
    RAISE NOTICE 'WARNING: Table %.% had no audit log trigger',
      trigger_audit_log_drop.schema_name, trigger_audit_log_drop.table_name;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.trigger_audit_log_drop(TEXT,TEXT) IS 'Function dropping all audit log triggers for a single table.';


CREATE FUNCTION vibetype_private.trigger_audit_log_enable_multiple()
RETURNS void AS $$
DECLARE
  _record RECORD;
BEGIN
  FOR _record IN
    SELECT trigger_name, schema_name, table_name
      FROM vibetype_private.audit_log_trigger
      WHERE trigger_enabled = 'D'
  LOOP
    EXECUTE 'ALTER TABLE ' || _record.schema_name || '.' || _record.table_name || ' ENABLE TRIGGER ' || _record.trigger_name;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.trigger_audit_log_enable_multiple() IS 'Function enabling all audit log triggers that are currently disabled.';


CREATE FUNCTION vibetype_private.trigger_audit_log_enable (
  schema_name TEXT,
  table_name TEXT
) RETURNS void AS $$
DECLARE
  _record RECORD;
  _i INTEGER := 0;
BEGIN
  FOR _record IN
    SELECT t.trigger_name, t.schema_name, t.table_name, t.trigger_enabled
      FROM vibetype_private.audit_log_trigger t
      WHERE t.schema_name = trigger_audit_log_enable.schema_name
        AND t.table_name = trigger_audit_log_enable.table_name
  LOOP
    _i := _i + 1;

    IF _record.trigger_enabled = 'D' THEN
      EXECUTE 'ALTER TABLE ' || _record.schema_name || '.' || _record.table_name || ' ENABLE TRIGGER ' || _record.trigger_name;
    END IF;
  END LOOP;

  IF _i = 0 THEN
    RAISE NOTICE 'WARNING: Table %.% has no audit log trigger', trigger_audit_log_enable.schema_name, trigger_audit_log_enable.table_name;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.trigger_audit_log_enable(TEXT,TEXT) IS 'Function enabling audit log triggers for a single table.';


CREATE FUNCTION vibetype_private.trigger_audit_log_disable_multiple()
RETURNS void AS $$
DECLARE
  _record RECORD;
BEGIN
  FOR _record IN
    SELECT trigger_name, schema_name, table_name
      FROM vibetype_private.audit_log_trigger
      WHERE trigger_enabled != 'D'
  LOOP
    EXECUTE 'ALTER TABLE ' || _record.schema_name || '.' || _record.table_name || ' DISABLE TRIGGER ' || _record.trigger_name;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.trigger_audit_log_disable_multiple() IS 'Function disabling all audit log triggers that are currently enabled.';


CREATE FUNCTION vibetype_private.trigger_audit_log_disable (
  schema_name TEXT,
  table_name TEXT
) RETURNS void AS $$
DECLARE
  _record RECORD;
  _i INTEGER := 0;
BEGIN
  FOR _record IN
    SELECT t.trigger_name, t.schema_name, t.table_name, t.trigger_enabled
      FROM vibetype_private.audit_log_trigger t
      WHERE t.schema_name = trigger_audit_log_disable.schema_name
        AND t.table_name = trigger_audit_log_disable.table_name
  LOOP
    _i := _i + 1;

    IF _record.trigger_enabled != 'D' THEN
      EXECUTE 'ALTER TABLE ' || _record.schema_name || '.' || _record.table_name || ' DISABLE TRIGGER ' || _record.trigger_name;
    END IF;
  END LOOP;

  IF _i = 0 THEN
    RAISE NOTICE 'WARNING: Table %.% has no audit log trigger', trigger_audit_log_enable.schema_name, trigger_audit_log_enable.table_name;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.trigger_audit_log_disable(TEXT,TEXT) IS 'Function disabling an audit log triggers that are currently enabled.';


CREATE FUNCTION vibetype_private.adjust_audit_log_id_seq ()
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

COMMENT ON FUNCTION vibetype_private.adjust_audit_log_id_seq() IS 'Function resetting the current value of the sequence vibetype_private.audit_log_id_seq according to the content of table audit_log.';

COMMIT;
