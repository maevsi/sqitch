\echo test_device/constraints...

BEGIN;

-- Test fcm_token field with exactly 300 characters (boundary)
SAVEPOINT device_register_fcm_token_exact_300;
DO $$
DECLARE
  accountA UUID;
  _device vibetype.device;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  _device := vibetype.device_register(repeat('a', 300), 'web');

  IF _device.id IS NULL THEN
    RAISE EXCEPTION 'Test failed (device_register_fcm_token_exact_300): device not created';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT device_register_fcm_token_exact_300;

-- Test fcm_token field with 301 characters (should fail)
SAVEPOINT device_register_fcm_token_too_long;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    PERFORM vibetype.device_register(repeat('a', 301), 'web');
    RAISE EXCEPTION 'Test failed (device_register_fcm_token_too_long): fcm_token with 301 characters accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT device_register_fcm_token_too_long;

-- Test fcm_token field being empty (should fail)
SAVEPOINT device_register_fcm_token_empty;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    PERFORM vibetype.device_register('', 'web');
    RAISE EXCEPTION 'Test failed (device_register_fcm_token_empty): empty fcm_token accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT device_register_fcm_token_empty;

-- Test label field with exactly 100 characters (boundary)
SAVEPOINT device_register_label_exact_100;
DO $$
DECLARE
  accountA UUID;
  _device vibetype.device;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  _device := vibetype.device_register('token', 'web', repeat('a', 100));

  IF _device.label IS DISTINCT FROM repeat('a', 100) THEN
    RAISE EXCEPTION 'Test failed (device_register_label_exact_100): label not stored';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT device_register_label_exact_100;

-- Test label field with 101 characters (should fail)
SAVEPOINT device_register_label_too_long;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    PERFORM vibetype.device_register('token', 'web', repeat('a', 101));
    RAISE EXCEPTION 'Test failed (device_register_label_too_long): label with 101 characters accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT device_register_label_too_long;

-- Test label field being empty (should fail)
SAVEPOINT device_register_label_empty;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    PERFORM vibetype.device_register('token', 'web', '');
    RAISE EXCEPTION 'Test failed (device_register_label_empty): empty label accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT device_register_label_empty;

ROLLBACK;
