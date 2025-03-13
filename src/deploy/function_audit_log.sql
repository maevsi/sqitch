
BEGIN;
-- =========================================================
-- Several utility functions for managing audit log triggers
-- =========================================================


-- generic audit trigger function
-- implementation inspired by https://medium.com/israeli-tech-radar/postgresql-trigger-based-audit-log-fd9d9d5e412c

CREATE OR REPLACE FUNCTION vibetype_private.audit_trigger()
RETURNS TRIGGER AS $$
DECLARE
  new_data jsonb;
  old_data jsonb;
  key text;
  new_values jsonb;
  old_values jsonb;
  account_id UUID;
  user_name text;
BEGIN
  account_id := NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID;

  IF account_id IS NULL THEN
    user_name := current_user;
  ELSE
    SELECT username INTO user_name
    FROM vibetype.account
    WHERE id = account_id;
  END IF;

  new_values := '{}';
  old_values := '{}';

  IF TG_OP = 'INSERT' THEN
    new_data := to_jsonb(NEW);
    new_values := new_data;

  ELSIF TG_OP = 'UPDATE' THEN
    new_data := to_jsonb(NEW);
    old_data := to_jsonb(OLD);

    FOR key IN SELECT jsonb_object_keys(new_data) INTERSECT SELECT jsonb_object_keys(old_data)
    LOOP
      IF new_data ->> key != old_data ->> key THEN
        new_values := new_values || jsonb_build_object(key, new_data ->> key);
        old_values := old_values || jsonb_build_object(key, old_data ->> key);
      END IF;
    END LOOP;

  ELSIF TG_OP = 'DELETE' THEN
    old_data := to_jsonb(OLD);
    old_values := old_data;

    FOR key IN SELECT jsonb_object_keys(old_data)
    LOOP
      old_values := old_values || jsonb_build_object(key, old_data ->> key);
    END LOOP;

  END IF;

  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    INSERT INTO vibetype_private.audit_log (schema_name, table_name, record_id, operation_type, changed_by, old_values, new_values)
    VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, NEW.id, TG_OP, user_name, old_values, new_values);

    RETURN NEW;
  ELSE
    INSERT INTO vibetype_private.audit_log (schema_name, table_name, record_id, operation_type, changed_by, old_values, new_values)
    VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, OLD.id, TG_OP, user_name, old_values, new_values);

    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.audit_trigger() IS 'Trigger function creating records in table vibetype_private.audit_log.';


-- create all audit log triggers for all tables

CREATE OR REPLACE FUNCTION vibetype_private.create_audit_log_triggers()
RETURNS void AS $$
DECLARE
  -- PostgreSql Documentation, section 37.1:
  -- If more than one trigger is defined for the same event on the same relation, the triggers will be fired in alphabetical order by trigger name.
  trigger_name TEXT := 'zzz_audit_log_trigger';
  rec RECORD;
BEGIN

  FOR rec IN
    SELECT n.nspname ,c.relname
    FROM pg_catalog.pg_class c
      -- audit log triggers works only for tables having an id column
      JOIN pg_catalog.pg_attribute a ON c.oid = a.attrelid AND a.attname = 'id'
      JOIN pg_catalog.pg_namespace n ON c.relnamespace = n.oid
    WHERE c.relkind = 'r' AND n.nspname in ('vibetype', 'vibetype_private')
      -- negative list, make sure that at least audit_log table is not audited
      and (n.nspname, c.relname) not in (
        ('vibetype_private', 'audit_log'),
        ('vibetype_private', 'jwt')
      )
  LOOP

     EXECUTE 'CREATE TRIGGER ' || trigger_name ||
      ' BEFORE INSERT OR UPDATE OR DELETE ON ' ||
      rec.nspname || '.' || rec.relname ||
      ' FOR EACH ROW EXECUTE FUNCTION vibetype_private.audit_trigger()';

  END LOOP;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.create_audit_log_triggers() IS 'Function creating all audit log triggers for all tables that should be audited.';


-- create audit log triggers for a single table

CREATE OR REPLACE FUNCTION vibetype_private.create_audit_log_trigger_for_table (
  schema_name TEXT,
  table_name TEXT
) RETURNS void AS $$
DECLARE
  trigger_name TEXT := 'zzz_audit_log_trigger';
BEGIN

  IF EXISTS(
    SELECT 1
    FROM pg_catalog.pg_class c
      -- audit log triggers works only for tables having an id column
      JOIN pg_catalog.pg_attribute a ON c.oid = a.attrelid AND a.attname = 'id'
      JOIN pg_catalog.pg_namespace n ON c.relnamespace = n.oid
    WHERE c.relkind = 'r'
      AND n.nspname = create_audit_log_trigger_for_table.schema_name
      AND c.relname = create_audit_log_trigger_for_table.table_name
      -- negative list, make sure that at least audit_log table is not audited
      AND (n.nspname, c.relname) not in (
        ('vibetype_private', 'audit_log'),
        ('vibetype_private', 'jwt')
      )
  ) THEN

    EXECUTE 'CREATE TRIGGER ' || trigger_name ||
    ' BEFORE INSERT OR UPDATE OR DELETE ON ' ||
    create_audit_log_trigger_for_table.schema_name || '.' || create_audit_log_trigger_for_table.table_name ||
    ' FOR EACH ROW EXECUTE FUNCTION vibetype_private.audit_trigger()';

  ELSE
    RAISE EXCEPTION 'Table %.% cannot have an audit log trigger.',
      create_audit_log_trigger_for_table.schema_name, create_audit_log_trigger_for_table.table_name;
  END IF;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.create_audit_log_trigger_for_table(TEXT,TEXT)
  IS 'Function creating an audit log trigger for a single table.';


-- drop all audit log triggers

CREATE OR REPLACE FUNCTION vibetype_private.drop_audit_log_triggers()
RETURNS void AS $$
DECLARE
  rec RECORD;
BEGIN

  FOR rec IN
    SELECT trigger_name, schema_name, table_name
    FROM vibetype_private.audit_log_trigger
  LOOP

    EXECUTE 'DROP TRIGGER ' || rec.trigger_name || ' ON ' ||
      rec.schema_name || '.' || rec.table_name;

  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.drop_audit_log_triggers()
  IS 'Function dropping all audit log triggers for all tables that are currently audited.';

-- drop audit log triggers for a single table

CREATE OR REPLACE FUNCTION vibetype_private.drop_audit_log_trigger_for_table (
  schema_name TEXT,
  table_name TEXT
) RETURNS void AS $$
DECLARE
  rec RECORD;
  i INTEGER := 0;
BEGIN

  FOR rec IN
    SELECT t.trigger_name, t.schema_name, t.table_name
    FROM vibetype_private.audit_log_trigger t
    WHERE t.schema_name = drop_audit_log_trigger_for_table.schema_name
      AND t.table_name = drop_audit_log_trigger_for_table.table_name
  LOOP

    i := i + 1;

    EXECUTE 'DROP TRIGGER ' || rec.trigger_name || ' ON ' ||
      rec.schema_name || '.' || rec.table_name;

  END LOOP;

  IF i = 0 THEN
    RAISE NOTICE 'WARNING: Table %.% had no audit log trigger',
      drop_audit_log_trigger_for_table.schema_name, drop_audit_log_trigger_for_table.table_name;
  END IF;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.drop_audit_log_trigger_for_table(TEXT,TEXT)
  IS 'Function dropping all audit log triggers for a single table.';


-- enable all audit log triggers

CREATE OR REPLACE FUNCTION vibetype_private.enable_audit_log_triggers()
RETURNS void AS $$
DECLARE
  rec RECORD;
BEGIN

  FOR rec IN
    SELECT trigger_name, schema_name, table_name
    FROM vibetype_private.audit_log_trigger
    WHERE trigger_enabled = 'D'
  LOOP

    EXECUTE 'ALTER TABLE ' || rec.schema_name || '.' || rec.table_name ||
      ' ENABLE TRIGGER ' || rec.trigger_name;

  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.enable_audit_log_triggers()
  IS 'Function enabling all audit log triggers that are currently disabled.';


-- enable audit log trigger for a single table

CREATE OR REPLACE FUNCTION vibetype_private.enable_audit_log_trigger_for_table (
  schema_name TEXT,
  table_name TEXT
) RETURNS void AS $$
DECLARE
  rec RECORD;
  i INTEGER := 0;
BEGIN

  FOR rec IN
    SELECT t.trigger_name, t.schema_name, t.table_name, t.trigger_enabled
    FROM vibetype_private.audit_log_trigger t
    WHERE t.schema_name = enable_audit_log_trigger_for_table.schema_name
      and t.table_name = enable_audit_log_trigger_for_table.table_name
  LOOP

    i := i + 1;

    IF rec.trigger_enabled = 'D' THEN

      EXECUTE 'ALTER TABLE ' || rec.schema_name || '.' || rec.table_name ||
        ' ENABLE TRIGGER ' || rec.trigger_name;
    END IF;

  END LOOP;

  IF i = 0 THEN
    RAISE NOTICE 'WARNING: Table %.% has no audit log trigger',
      enable_audit_log_trigger_for_table.schema_name, enable_audit_log_trigger_for_table.table_name;
  END IF;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.enable_audit_log_trigger_for_table(TEXT,TEXT)
  IS 'Function enabling audit log triggers for a single table.';


-- disable all audit log triggers

CREATE OR REPLACE FUNCTION vibetype_private.disable_audit_log_triggers()
RETURNS void AS $$
DECLARE
  rec RECORD;
BEGIN

  FOR rec IN
    SELECT trigger_name, schema_name, table_name
    FROM vibetype_private.audit_log_trigger
    WHERE trigger_enabled != 'D'
  LOOP

    EXECUTE 'ALTER TABLE ' || rec.schema_name || '.' || rec.table_name ||
      ' DISABLE TRIGGER ' || rec.trigger_name;

  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.disable_audit_log_triggers()
  IS 'Function disabling all audit log triggers that are currently enabled.';


-- disable audit log trigger for a single table

CREATE OR REPLACE FUNCTION vibetype_private.disable_audit_log_trigger_for_table (
  schema_name TEXT,
  table_name TEXT
) RETURNS void AS $$
DECLARE
  rec RECORD;
  i INTEGER := 0;
BEGIN

  FOR rec IN
    SELECT t.trigger_name, t.schema_name, t.table_name, t.trigger_enabled
    FROM vibetype_private.audit_log_trigger t
    WHERE t.schema_name = disable_audit_log_trigger_for_table.schema_name
      and t.table_name = disable_audit_log_trigger_for_table.table_name
  LOOP

    i := i + 1;

    IF rec.trigger_enabled != 'D' THEN

      EXECUTE 'ALTER TABLE ' || rec.schema_name || '.' || rec.table_name ||
        ' DISABLE TRIGGER ' || rec.trigger_name;
    END IF;

  END LOOP;

  IF i = 0 THEN
    RAISE NOTICE 'WARNING: Table %.% has no audit log trigger',
      enable_audit_log_trigger_for_table.schema_name, enable_audit_log_trigger_for_table.table_name;
  END IF;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.disable_audit_log_trigger_for_table(TEXT,TEXT)
  IS 'Function disabling an audit log triggers that are currently enabled.';


-- adjust sequence associated with primary key of table audit_log

CREATE OR REPLACE FUNCTION vibetype_private.adjust_audit_log_id_seq ()
RETURNS void AS $$
DECLARE
  max_val INTEGER;
BEGIN
  SELECT MAX(id) INTO max_val
  FROM vibetype_private.audit_log;

  PERFORM setval(
    'vibetype_private.audit_log_id_seq',
    CASE WHEN max_val IS NOT NULL THEN max_val + 1 ELSE 1 END,
    false
  );
END; $$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.adjust_audit_log_id_seq()
  IS 'Function resetting the current value of the sequence vibetype_private.audit_log_id_seq according to the content of table audit_log.';

COMMIT;