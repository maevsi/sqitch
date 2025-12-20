\echo test_jwt_update...

BEGIN;

SAVEPOINT jwt_update_success;
DO $$
DECLARE
  _jwt vibetype.jwt;
  _jwt_updated vibetype.jwt;
  _jwt_id UUID;
  _exp_before BIGINT;
  _exp_after BIGINT;
BEGIN
  PERFORM vibetype_test.account_registration_verified ('username', 'email@example.com');

  _jwt := vibetype.jwt_create('username', 'password');
  IF _jwt IS NULL THEN
    RAISE EXCEPTION 'Test failed: jwt_create should return a JWT';
  END IF;

  _jwt_id := _jwt.jti;
  _exp_before := _jwt.exp;

  _jwt_updated := vibetype.jwt_update(_jwt_id);
  IF _jwt_updated IS NULL THEN
    RAISE EXCEPTION 'Test failed: jwt_update should return a JWT';
  END IF;

  _exp_after := _jwt_updated.exp;

  IF _exp_after < _exp_before THEN
    RAISE EXCEPTION 'Test failed: jwt_update should not reduce exp';
  END IF;

  IF _jwt_updated.sub IS NULL OR _jwt_updated.username IS NULL THEN
    RAISE EXCEPTION 'Test failed: jwt_update should preserve subject and username';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT jwt_update_success;

ROLLBACK;
