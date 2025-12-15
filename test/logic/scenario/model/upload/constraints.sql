\echo test_upload/constraints...

BEGIN;

-- Test name field with exactly 300 characters (boundary)
SAVEPOINT upload_insert_name_exact_300;
DO $$
DECLARE
  accountA UUID;
  name_300 TEXT := repeat('a', 300);
  upload_id UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.upload(created_by, name, size_byte)
  VALUES (accountA, name_300, 1024)
  RETURNING id INTO upload_id;

  IF upload_id IS NULL THEN
    RAISE EXCEPTION 'Test failed (upload_insert_name_exact_300): upload not created';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT upload_insert_name_exact_300;

-- Test name field with 301 characters (should fail)
SAVEPOINT upload_insert_name_too_long;
DO $$
DECLARE
  accountA UUID;
  name_301 TEXT := repeat('a', 301);
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    INSERT INTO vibetype.upload(created_by, name, size_byte)
    VALUES (accountA, name_301, 1024);
    RAISE EXCEPTION 'Test failed (upload_insert_name_too_long): name with 301 characters accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT upload_insert_name_too_long;

ROLLBACK;
