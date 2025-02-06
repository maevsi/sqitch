BEGIN;

CREATE TABLE maevsi_test.base (id UUID PRIMARY KEY, text TEXT);
CREATE INDEX idx_base_text ON maevsi_test.base USING btree (text);
CREATE TABLE maevsi.depentent (base_id UUID REFERENCES maevsi_test.base(id));
CREATE INDEX idx_dependent_base_id ON maevsi.depentent USING btree (base_id);

SAVEPOINT schema_implicit;
DO $$
BEGIN
  PERFORM maevsi_test.index_existence(
    ARRAY ['idx_dependent_base_id']
  );
END $$;
ROLLBACK TO SAVEPOINT schema_implicit;


SAVEPOINT schema_implicit_failure;
DO $$
BEGIN
  BEGIN
    PERFORM maevsi_test.index_existence(
      ARRAY['does-not-exist']
    );
  EXCEPTION WHEN OTHERS THEN
    RETURN;
  END;

  RAISE EXCEPTION 'Test failed: did not fail for index that does not exist.';
END $$;
ROLLBACK TO SAVEPOINT schema_implicit_failure;


SAVEPOINT schema_explicit;
DO $$
BEGIN
  PERFORM maevsi_test.index_existence(
    ARRAY ['base_pkey'],
    'maevsi_test'
  );
END $$;
ROLLBACK TO SAVEPOINT schema_explicit;


SAVEPOINT schema_explicit_failure;
DO $$
BEGIN
  BEGIN
    PERFORM maevsi_test.index_existence(
      ARRAY['does-not-exist'],
      'maevsi_test'
    );
  EXCEPTION WHEN OTHERS THEN
    RETURN;
  END;

  RAISE EXCEPTION 'Test failed: did not fail for index that does not exist in a custom schema.';
END $$;
ROLLBACK TO SAVEPOINT schema_explicit_failure;


SAVEPOINT schema_explicit_default;
DO $$
BEGIN
  PERFORM maevsi_test.index_existence(
    ARRAY ['idx_dependent_base_id'],
    'maevsi'
  );
END $$;
ROLLBACK TO SAVEPOINT schema_explicit_default;


SAVEPOINT schema_explicit_default_failure;
DO $$
BEGIN
  BEGIN
    PERFORM maevsi_test.index_existence(
      ARRAY['does-not-exist'],
      'maevsi'
    );
  EXCEPTION WHEN OTHERS THEN
    RETURN;
  END;

  RAISE EXCEPTION 'Test failed: did not fail for index that does not exist in the explicitly given default schema.';
END $$;
ROLLBACK TO SAVEPOINT schema_explicit_default_failure;


SAVEPOINT schema_implicit_multiple;
DO $$
BEGIN
  PERFORM maevsi_test.index_existence(
    ARRAY ['base_pkey', 'idx_base_text'],
    'maevsi_test'
  );
END $$;
ROLLBACK TO SAVEPOINT schema_implicit_multiple;


SAVEPOINT schema_implicit_multiple_failure;
DO $$
BEGIN
  BEGIN
    PERFORM maevsi_test.index_existence(
      ARRAY['base_pkey', 'does-not-exist'],
      'maevsi_test'
    );
  EXCEPTION WHEN OTHERS THEN
    RETURN;
  END;

  RAISE EXCEPTION 'Test failed: did not fail for index that does not exist in the explicitly given default schema.';
END $$;
ROLLBACK TO SAVEPOINT schema_implicit_multiple_failure;

DROP INDEX maevsi.idx_dependent_base_id;
DROP TABLE maevsi.depentent;
DROP INDEX maevsi_test.idx_base_text;
DROP TABLE maevsi_test.base;

COMMIT;