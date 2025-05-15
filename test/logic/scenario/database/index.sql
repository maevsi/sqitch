\echo test_index...

-- test for existance of index on foreign keys

SELECT vibetype_test.index_on_foreign_key_check();

BEGIN;

-- test function vibetype_test.index_existence

CREATE TABLE vibetype_test.base (id UUID PRIMARY KEY, text TEXT);
CREATE INDEX idx_base_text ON vibetype_test.base USING btree (text);
CREATE TABLE vibetype.dependent (base_id UUID REFERENCES vibetype_test.base(id) ON DELETE CASCADE);
CREATE INDEX idx_dependent_base_id ON vibetype.dependent USING btree (base_id);

SAVEPOINT schema_implicit;
DO $$
BEGIN
  PERFORM vibetype_test.index_existence(
    ARRAY ['idx_dependent_base_id']
  );
END $$;
ROLLBACK TO SAVEPOINT schema_implicit;


SAVEPOINT schema_implicit_failure;
DO $$
BEGIN
  BEGIN
    PERFORM vibetype_test.index_existence(
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
  PERFORM vibetype_test.index_existence(
    ARRAY ['base_pkey'],
    'vibetype_test'
  );
END $$;
ROLLBACK TO SAVEPOINT schema_explicit;


SAVEPOINT schema_explicit_failure;
DO $$
BEGIN
  BEGIN
    PERFORM vibetype_test.index_existence(
      ARRAY['does-not-exist'],
      'vibetype_test'
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
  PERFORM vibetype_test.index_existence(
    ARRAY ['idx_dependent_base_id'],
    'vibetype'
  );
END $$;
ROLLBACK TO SAVEPOINT schema_explicit_default;


SAVEPOINT schema_explicit_default_failure;
DO $$
BEGIN
  BEGIN
    PERFORM vibetype_test.index_existence(
      ARRAY['does-not-exist'],
      'vibetype'
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
  PERFORM vibetype_test.index_existence(
    ARRAY ['base_pkey', 'idx_base_text'],
    'vibetype_test'
  );
END $$;
ROLLBACK TO SAVEPOINT schema_implicit_multiple;


SAVEPOINT schema_implicit_multiple_failure;
DO $$
BEGIN
  BEGIN
    PERFORM vibetype_test.index_existence(
      ARRAY['base_pkey', 'does-not-exist'],
      'vibetype_test'
    );
  EXCEPTION WHEN OTHERS THEN
    RETURN;
  END;

  RAISE EXCEPTION 'Test failed: did not fail for index that does not exist in the explicitly given default schema.';
END $$;
ROLLBACK TO SAVEPOINT schema_implicit_multiple_failure;

DROP INDEX vibetype.idx_dependent_base_id;
DROP TABLE vibetype.dependent;
DROP INDEX vibetype_test.idx_base_text;
DROP TABLE vibetype_test.base;

COMMIT;

-- test for the existence of individual indexes

SELECT vibetype_test.index_existence(
  ARRAY ['idx_account_private_location'],
  'vibetype_private'
);

SELECT vibetype_test.index_existence(
  ARRAY ['account_block_created_by_blocked_account_id_key']
);

SELECT vibetype_test.index_existence(
  ARRAY ['idx_address_location', 'idx_address_created_by', 'idx_address_updated_by']
);

SELECT vibetype_test.index_existence(
  ARRAY ['idx_device_updated_by', 'device_created_by_fcm_token_key']
);

SELECT vibetype_test.index_existence(
  ARRAY ['event_created_by_slug_key', 'idx_event_search_vector']
);

SELECT vibetype_test.index_existence(
  ARRAY ['idx_friendship_created_by', 'idx_friendship_updated_by']
);

SELECT vibetype_test.index_existence(
  ARRAY ['guest_event_id_contact_id_key', 'idx_guest_updated_by']
);
