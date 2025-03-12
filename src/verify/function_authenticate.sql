BEGIN;

SAVEPOINT privileges;
DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.authenticate(TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_account does not have EXECUTE privilege';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.authenticate(TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_anonymous does not have EXECUTE privilege';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT privileges;

SAVEPOINT username_success;
DO $$
DECLARE
  _account_id UUID;
  _jwt vibetype.jwt;
BEGIN
  _account_id := vibetype.account_registration('username', 'email@example.com', 'password', 'en');
  PERFORM vibetype.account_email_address_verification(
    (SELECT email_address_verification FROM vibetype_private.account WHERE id = _account_id)
  );

  _jwt := vibetype.authenticate('username', 'password');

  IF _jwt IS NULL THEN
    RAISE EXCEPTION 'Test failed: Authentication should have returned a JWT';
  END IF;

  IF _jwt.account_username <> 'username' THEN
    RAISE EXCEPTION 'Test failed: JWT contains an incorrect username';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT username_success;

SAVEPOINT username_incorrect;
DO $$
DECLARE
  _account_id UUID;
  _jwt vibetype.jwt;
BEGIN
  _account_id := vibetype.account_registration('username', 'email@example.com', 'password', 'en');
  PERFORM vibetype.account_email_address_verification(
    (SELECT email_address_verification FROM vibetype_private.account WHERE id = _account_id)
  );

  BEGIN
    _jwt := vibetype.authenticate('username_incorrect', 'password');
  EXCEPTION WHEN no_data_found THEN
    NULL;
  END;
END $$;
ROLLBACK TO SAVEPOINT username_incorrect;

SAVEPOINT username_password_incorrect;
DO $$
DECLARE
  _account_id UUID;
  _jwt vibetype.jwt;
BEGIN
  _account_id := vibetype.account_registration('username', 'email@example.com', 'password', 'en');
  PERFORM vibetype.account_email_address_verification(
    (SELECT email_address_verification FROM vibetype_private.account WHERE id = _account_id)
  );

  BEGIN
    _jwt := vibetype.authenticate('username', 'password_incorrect');
  EXCEPTION WHEN no_data_found THEN
    NULL;
  END;

  IF _jwt IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: Authentication should not have returned a JWT';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT username_password_incorrect;

SAVEPOINT email_success;
DO $$
DECLARE
  _account_id UUID;
  _jwt vibetype.jwt;
BEGIN
  _account_id := vibetype.account_registration('username', 'email@example.com', 'password', 'en');
  PERFORM vibetype.account_email_address_verification(
    (SELECT email_address_verification FROM vibetype_private.account WHERE id = _account_id)
  );

  _jwt := vibetype.authenticate('email@example.com', 'password');

  IF _jwt IS NULL THEN
    RAISE EXCEPTION 'Test failed: Authentication should have returned a JWT';
  END IF;

  IF _jwt.account_username <> 'username' THEN
    RAISE EXCEPTION 'Test failed: JWT contains an incorrect user name';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT email_success;

SAVEPOINT email_incorrect;
DO $$
DECLARE
  _account_id UUID;
  _jwt vibetype.jwt;
BEGIN
  _account_id := vibetype.account_registration('username', 'email@example.com', 'password', 'en');
  PERFORM vibetype.account_email_address_verification(
    (SELECT email_address_verification FROM vibetype_private.account WHERE id = _account_id)
  );

  BEGIN
    _jwt := vibetype.authenticate('email_incorrect@example.com', 'password');
  EXCEPTION WHEN no_data_found THEN
    NULL;
  END;

  IF _jwt IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: Authentication should not have returned a JWT';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT email_incorrect;

SAVEPOINT email_password_incorrect;
DO $$
DECLARE
  _account_id UUID;
  _jwt vibetype.jwt;
BEGIN
  _account_id := vibetype.account_registration('username', 'email@example.com', 'password', 'en');
  PERFORM vibetype.account_email_address_verification(
    (SELECT email_address_verification FROM vibetype_private.account WHERE id = _account_id)
  );

  BEGIN
    _jwt := vibetype.authenticate('email@example.com', 'password_incorrect');
  EXCEPTION WHEN no_data_found THEN
    NULL;
  END;

  IF _jwt IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: Authentication should not have returned a JWT';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT email_password_incorrect;

ROLLBACK;
