\echo test_trigger_metadata_update...

BEGIN;

SAVEPOINT update_sets_updated_at_and_updated_by;
DO $$
DECLARE
  _account_id UUID;
  _updated_at TIMESTAMPTZ;
  _updated_by UUID;
BEGIN
  _account_id := vibetype_test.account_registration_verified('testuser', 'test@example.com');

  CREATE TEMP TABLE test_metadata_full (
    id SERIAL PRIMARY KEY,
    updated_at TIMESTAMPTZ,
    updated_by UUID
  ) ON COMMIT DROP;

  CREATE TRIGGER trigger_metadata_update
    BEFORE UPDATE ON test_metadata_full
    FOR EACH ROW EXECUTE FUNCTION vibetype.trigger_metadata_update();

  INSERT INTO test_metadata_full DEFAULT VALUES;

  PERFORM set_config('jwt.claims.sub', _account_id::TEXT, true);
  UPDATE test_metadata_full SET id = id WHERE id = 1;
  PERFORM set_config('jwt.claims.sub', '', true);

  SELECT updated_at, updated_by INTO _updated_at, _updated_by
    FROM test_metadata_full
    WHERE id = 1;

  IF _updated_at IS NULL THEN
    RAISE EXCEPTION 'updated_at was not set on a table with updated_at and updated_by';
  END IF;

  IF _updated_by IS DISTINCT FROM _account_id THEN
    RAISE EXCEPTION 'updated_by was not set to the invoker account id';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT update_sets_updated_at_and_updated_by;

SAVEPOINT update_sets_updated_at_without_updated_by;
DO $$
DECLARE
  _updated_at TIMESTAMPTZ;
BEGIN
  CREATE TEMP TABLE test_metadata_updated_at_only (
    id SERIAL PRIMARY KEY,
    updated_at TIMESTAMPTZ
  ) ON COMMIT DROP;

  CREATE TRIGGER trigger_metadata_update
    BEFORE UPDATE ON test_metadata_updated_at_only
    FOR EACH ROW EXECUTE FUNCTION vibetype.trigger_metadata_update();

  INSERT INTO test_metadata_updated_at_only DEFAULT VALUES;

  UPDATE test_metadata_updated_at_only SET id = id WHERE id = 1;

  SELECT updated_at INTO _updated_at FROM test_metadata_updated_at_only WHERE id = 1;

  IF _updated_at IS NULL THEN
    RAISE EXCEPTION 'updated_at was not set on a table without updated_by';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT update_sets_updated_at_without_updated_by;

ROLLBACK;

