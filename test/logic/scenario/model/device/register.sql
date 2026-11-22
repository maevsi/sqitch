\echo test_device/register...

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

BEGIN;

SET LOCAL role.vibetype_username TO :'role_service_vibetype_username';

-- registering creates a row owned by the invoker
SAVEPOINT device_register_create;
DO $$
DECLARE
  _a UUID;
  _device vibetype.device;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(_a);

  _device := vibetype.device_register('token-a', 'android', 'Chrome on Android');

  IF _device.id IS NULL
    OR _device.created_by IS DISTINCT FROM _a
    OR _device.fcm_token IS DISTINCT FROM 'token-a'
    OR _device.platform IS DISTINCT FROM 'android'
    OR _device.label IS DISTINCT FROM 'Chrome on Android'
    OR _device.last_seen_at IS NULL
  THEN
    RAISE EXCEPTION 'Test failed (device_register_create): unexpected device %', _device;
  END IF;

  IF (SELECT count(*) FROM vibetype.device) != 1 THEN
    RAISE EXCEPTION 'Test failed (device_register_create): the invoker does not see the device';
  END IF;

  -- the label is optional
  _device := vibetype.device_register('token-b', 'ios');

  IF _device.label IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed (device_register_create): label without a value is set';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT device_register_create;

-- registering needs an account
SAVEPOINT device_register_no_account;
DO $$
DECLARE
  _a UUID;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set_anonymous();
  BEGIN
    PERFORM vibetype.device_register('token', 'web');
    RAISE EXCEPTION 'Test failed (device_register_no_account): an anonymous user registered a device';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_a);
  PERFORM set_config('jwt.claims.sub', '', true);
  BEGIN
    PERFORM vibetype.device_register('token', 'web');
    RAISE EXCEPTION 'Test failed (device_register_no_account): a registration without an account was accepted';
  EXCEPTION WHEN SQLSTATE 'VTDNA' THEN
    NULL;
  END;
  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT device_register_no_account;

-- a token moves to the account that registers it last
SAVEPOINT device_register_takeover;
DO $$
DECLARE
  _a UUID;
  _b UUID;
  _id UUID;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _b := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.invoker_set(_a);
  _id := (vibetype.device_register('token', 'web', 'Firefox on Linux')).id;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_b);
  IF (SELECT count(*) FROM vibetype.device) != 0 THEN
    RAISE EXCEPTION 'Test failed (device_register_takeover): an account sees the device of another';
  END IF;
  IF (vibetype.device_register('token', 'ios', 'Safari on iPhone')).id IS DISTINCT FROM _id THEN
    RAISE EXCEPTION 'Test failed (device_register_takeover): the registration was not taken over in place';
  END IF;
  IF (SELECT count(*) FROM vibetype.device WHERE created_by = _b AND platform = 'ios' AND label = 'Safari on iPhone') != 1 THEN
    RAISE EXCEPTION 'Test failed (device_register_takeover): the new owner does not see the device';
  END IF;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_a);
  IF (SELECT count(*) FROM vibetype.device) != 0 THEN
    RAISE EXCEPTION 'Test failed (device_register_takeover): the previous owner still sees the device';
  END IF;
  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT device_register_takeover;

-- registering again refreshes the registration
SAVEPOINT device_register_refresh;
DO $$
DECLARE
  _a UUID;
  _device vibetype.device;
  _old TIMESTAMPTZ := CURRENT_TIMESTAMP - INTERVAL '30 days';
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set(_a);
  _device := vibetype.device_register('token', 'web', 'Firefox on Linux');
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.account_notification_exec(format('UPDATE vibetype.device SET last_seen_at = %L WHERE id = %L', _old, _device.id));

  PERFORM vibetype_test.invoker_set(_a);
  _device := vibetype.device_register('token', 'android', NULL);

  IF _device.last_seen_at <= _old
    OR _device.platform IS DISTINCT FROM 'android'
    OR _device.label IS NOT NULL
    OR (SELECT count(*) FROM vibetype.device) != 1
  THEN
    RAISE EXCEPTION 'Test failed (device_register_refresh): unexpected device %', _device;
  END IF;
  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT device_register_refresh;

-- registering prunes registrations that were not refreshed for 90 days
SAVEPOINT device_register_prune;
DO $$
DECLARE
  _a UUID;
  _b UUID;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _b := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.invoker_set(_a);
  PERFORM vibetype.device_register('token-stale', 'web');
  PERFORM vibetype.device_register('token-fresh', 'web');
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.account_notification_exec('UPDATE vibetype.device SET last_seen_at = CURRENT_TIMESTAMP - INTERVAL ''91 days'' WHERE fcm_token = ''token-stale''');

  PERFORM vibetype_test.invoker_set(_b);
  PERFORM vibetype.device_register('token-b', 'web');
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_a);
  IF (SELECT array_agg(fcm_token) FROM vibetype.device) IS DISTINCT FROM ARRAY['token-fresh'] THEN
    RAISE EXCEPTION 'Test failed (device_register_prune): the stale registration of another account was not pruned';
  END IF;
  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT device_register_prune;

-- clients cannot write directly
SAVEPOINT device_write_direct;
DO $$
DECLARE
  _a UUID;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set(_a);
  PERFORM vibetype.device_register('token', 'web');

  BEGIN
    INSERT INTO vibetype.device (created_by, fcm_token, platform) VALUES (_a, 'token-direct', 'web');
    RAISE EXCEPTION 'Test failed (device_write_direct): an account inserted a device directly';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  BEGIN
    UPDATE vibetype.device SET label = 'changed';
    RAISE EXCEPTION 'Test failed (device_write_direct): an account updated a device directly';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT device_write_direct;

-- the owner can delete a device, others cannot
SAVEPOINT device_delete;
DO $$
DECLARE
  _a UUID;
  _b UUID;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _b := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.invoker_set(_a);
  PERFORM vibetype.device_register('token-a', 'web');
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_b);
  PERFORM vibetype.device_register('token-b', 'web');

  DELETE FROM vibetype.device WHERE fcm_token = 'token-a';
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_a);
  IF (SELECT count(*) FROM vibetype.device WHERE fcm_token = 'token-a') != 1 THEN
    RAISE EXCEPTION 'Test failed (device_delete): an account deleted the device of another';
  END IF;

  DELETE FROM vibetype.device WHERE fcm_token = 'token-a';
  IF (SELECT count(*) FROM vibetype.device) != 0 THEN
    RAISE EXCEPTION 'Test failed (device_delete): the owner could not delete the device';
  END IF;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_b);
  IF (SELECT count(*) FROM vibetype.device WHERE fcm_token = 'token-b') != 1 THEN
    RAISE EXCEPTION 'Test failed (device_delete): the device of another account was deleted';
  END IF;
  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT device_delete;

-- the service role reads and deletes devices of all accounts
SAVEPOINT device_service;
DO $$
DECLARE
  _a UUID;
  _b UUID;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _b := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.invoker_set(_a);
  PERFORM vibetype.device_register('token-a', 'web');
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_b);
  PERFORM vibetype.device_register('token-b', 'web');
  PERFORM vibetype_test.invoker_set_previous();

  EXECUTE format('SET LOCAL ROLE %I', current_setting('role.vibetype_username'));

  IF (SELECT count(*) FROM vibetype.device) != 2 THEN
    RAISE EXCEPTION 'Test failed (device_service): the service role cannot read all devices';
  END IF;

  DELETE FROM vibetype.device WHERE fcm_token = 'token-a';

  IF (SELECT array_agg(fcm_token) FROM vibetype.device) IS DISTINCT FROM ARRAY['token-b'] THEN
    RAISE EXCEPTION 'Test failed (device_service): the service role could not delete a device by token';
  END IF;

  BEGIN
    UPDATE vibetype.device SET label = 'changed';
    RAISE EXCEPTION 'Test failed (device_service): the service role updated a device';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
  SET LOCAL ROLE NONE;
END $$;
ROLLBACK TO SAVEPOINT device_service;

ROLLBACK;
