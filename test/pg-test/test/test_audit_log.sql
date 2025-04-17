\echo test_audit_log...

BEGIN;

DO $$
DECLARE
  _record Record;
  _count INTEGER;
BEGIN
  ---------------------------------------------------------
  -- drop all audit log triggers

  PERFORM vibetype_private.trigger_audit_log_drop_multiple();

  SELECT COUNT(*) INTO _count
    FROM vibetype_private.audit_log_trigger;

  IF _count != 0 THEN
    RAISE EXCEPTION 'There are still audit log triggers';
  END IF;

  ---------------------------------------------------------
  -- create all audit log triggers

  PERFORM vibetype_private.trigger_audit_log_create_multiple();

  -- check that no audit log triggers were created for vibetype_private.audit_log and vibetype_private.jwt

  SELECT COUNT(*) INTO _count
    FROM vibetype_private.audit_log_trigger
    WHERE schema_name = 'vibetype_private' AND table_name in ('audit_log', 'jwt');

  IF _count != 0 THEN
    RAISE EXCEPTION 'There must not be audit log triggers for vibetype_private.audit_log and vibetype_private.jwt';
  END IF;

  -- check that for all other tables with id column there is an audit log trigger

  _count := 0;

  FOR _record IN
    SELECT schemaname, tablename
      FROM pg_tables
      WHERE schemaname IN ('vibetype', 'vibetype_private')

    EXCEPT
      SELECT 'vibetype_private', 'audit_log' -- no audit log trigger for this table
    EXCEPT
      SELECT 'vibetype_private', 'jwt' -- no audit log trigger for this table
    EXCEPT
      SELECT schema_name, table_name
        FROM vibetype_private.audit_log_trigger
  LOOP
    IF EXISTS (
      -- if current table has an id column there should have been an audti log trigger
      SELECT 1
        FROM pg_catalog.pg_class c
          JOIN pg_catalog.pg_namespace n ON c.relnamespace = n.oid
          JOIN pg_catalog.pg_attribute a ON c.oid = a.attrelid
        WHERE c.relname = _record.tablename AND c.relkind = 'r'
          AND n.nspname = _record.schemaname AND a.attname = 'id'
    ) THEN
      _count := _count + 1;
      RAISE NOTICE 'Table % misses an audit log trigger', _record.schema_name || '.' || _record.table_name;
    END IF;
  END LOOP;

  IF _count != 0 THEN
    RAISE EXCEPTION 'There are tables that should have an audit log trigger but have not.';
  END IF;

  ---------------------------------------------------------
  -- disable all audit log triggers

  PERFORM vibetype_private.trigger_audit_log_disable_multiple();

  SELECT COUNT(*) INTO _count
    FROM vibetype_private.audit_log_trigger
    WHERE trigger_enabled != 'D';

  IF _count != 0 THEN
    RAISE EXCEPTION 'There is still an enabled audit log trigger.';
  END IF;

  ---------------------------------------------------------
  -- enable all audit log triggers

  PERFORM vibetype_private.trigger_audit_log_enable_multiple();

  SELECT COUNT(*) INTO _count
    FROM vibetype_private.audit_log_trigger
    WHERE trigger_enabled = 'D';

  IF _count != 0 THEN
    RAISE EXCEPTION 'There is still a disabled audit log trigger.';
  END IF;

  ---------------------------------------------------------
  -- disable the audit log trigger for a single table

  PERFORM vibetype_private.trigger_audit_log_disable ('vibetype', 'event');

  SELECT COUNT(*) INTO _count
    FROM vibetype_private.audit_log_trigger
    WHERE trigger_enabled != 'D'
      AND schema_name = 'vibetype' AND table_name = 'event';

  IF _count != 0 THEN
    RAISE EXCEPTION 'The audit log trigger on table vibetype.event is still enabled.';
  END IF;

  ---------------------------------------------------------
  -- enable the audit log trigger for a single table

  PERFORM vibetype_private.trigger_audit_log_enable ('vibetype', 'event');

  SELECT COUNT(*) INTO _count
    FROM vibetype_private.audit_log_trigger
    WHERE trigger_enabled = 'D'
      AND schema_name = 'vibetype' AND table_name = 'event';

  IF _count != 0 THEN
    RAISE EXCEPTION 'The audit log trigger on table vibetype.event is still disabled.';
  END IF;

  ---------------------------------------------------------
  -- drop all audit log triggers

  PERFORM vibetype_private.trigger_audit_log_drop_multiple();

  SELECT COUNT(*) INTO _count
    FROM vibetype_private.audit_log_trigger;

  IF _count != 0 THEN
    RAISE EXCEPTION 'There are still audit log triggers.';
  END IF;

  ---------------------------------------------------------
  -- create an audit log trigger for a single table

  PERFORM vibetype_private.trigger_audit_log_create('vibetype', 'event');

  SELECT COUNT(*) INTO _count
    FROM vibetype_private.audit_log_trigger
    WHERE schema_name = 'vibetype' AND table_name = 'event';

  IF _count != 1 THEN
    RAISE EXCEPTION 'The audit log trigger for table vibetype.event has not been created.';
  END IF;

  ---------------------------------------------------------
  -- drop the audit log trigger on a single table

  PERFORM vibetype_private.trigger_audit_log_drop('vibetype', 'event');

  SELECT COUNT(*) INTO _count
    FROM vibetype_private.audit_log_trigger
    WHERE schema_name = 'vibetype' AND table_name = 'event';

  IF _count != 0 THEN
    RAISE EXCEPTION 'The audit log trigger for table vibetype.event was not dropped.';
  END IF;
END;
$$ LANGUAGE plpgsql;

ROLLBACK;
