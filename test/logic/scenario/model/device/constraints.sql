\echo test_device/constraints...

BEGIN;

-- Test fcm_token field with exactly 300 characters (boundary)
SAVEPOINT device_insert_fcm_token_exact_300;
DO $$
DECLARE
  accountA UUID;
  fcm_token_300 TEXT := repeat('a', 300);
  device_id UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.device(created_by, fcm_token)
  VALUES (accountA, fcm_token_300)
  RETURNING id INTO device_id;

  IF device_id IS NULL THEN
    RAISE EXCEPTION 'Test failed (device_insert_fcm_token_exact_300): device not created';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT device_insert_fcm_token_exact_300;

-- Test fcm_token field with 301 characters (should fail)
SAVEPOINT device_insert_fcm_token_too_long;
DO $$
DECLARE
  accountA UUID;
  fcm_token_301 TEXT := repeat('a', 301);
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    INSERT INTO vibetype.device(created_by, fcm_token)
    VALUES (accountA, fcm_token_301);
    RAISE EXCEPTION 'Test failed (device_insert_fcm_token_too_long): fcm_token with 301 characters accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT device_insert_fcm_token_too_long;

ROLLBACK;
