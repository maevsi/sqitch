\echo test_table_jwt_expired_delete...

BEGIN;

SAVEPOINT expired_delete;
DO $$
DECLARE
  _expired_jti uuid;
  _live_jti uuid;
  _other_expired_jti uuid;
BEGIN
  PERFORM vibetype_test.account_registration_verified ('username', 'email@example.com');
  PERFORM vibetype_test.account_registration_verified ('other', 'other@example.com');

  PERFORM set_config('vibetype.jwt_expiry_duration', '1 hour', true);
  _live_jti := (vibetype.jwt_create('username', 'password')).jti;

  PERFORM set_config('vibetype.jwt_expiry_duration', '-1 hour', true);
  _expired_jti := (vibetype.jwt_create('username', 'password')).jti;
  _other_expired_jti := (vibetype.jwt_create('other', 'password')).jti;

  PERFORM set_config('vibetype.jwt_expiry_duration', '1 hour', true);

  PERFORM vibetype.jwt_create('username', 'password_incorrect');

  IF NOT EXISTS (SELECT 1 FROM vibetype_private.jwt WHERE id = _expired_jti) THEN
    RAISE EXCEPTION 'Test failed: A failed login should not delete expired tokens';
  END IF;

  PERFORM vibetype.jwt_create('username', 'password');

  IF EXISTS (SELECT 1 FROM vibetype_private.jwt WHERE id = _expired_jti) THEN
    RAISE EXCEPTION 'Test failed: The expired token of the account should have been deleted';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM vibetype_private.jwt WHERE id = _live_jti) THEN
    RAISE EXCEPTION 'Test failed: The live token of the account should have been kept';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM vibetype_private.jwt WHERE id = _other_expired_jti) THEN
    RAISE EXCEPTION 'Test failed: The expired token of another account should have been kept';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT expired_delete;

ROLLBACK;
