\echo test_session_create...

BEGIN;

SAVEPOINT privileges;
DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.session_create(TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_account does not have EXECUTE privilege';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.session_create(TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_anonymous does not have EXECUTE privilege';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT privileges;

SAVEPOINT username_success;
DO $$
DECLARE
  _session vibetype.session;
BEGIN
  PERFORM vibetype_test.account_registration_verified ('username', 'email@example.com');

  _session := vibetype.session_create('username', 'password');

  IF _session IS NULL THEN
    RAISE EXCEPTION 'Test failed: Authentication should have returned a session';
  END IF;

  IF _session.account_username <> 'username' THEN
    RAISE EXCEPTION 'Test failed: session contains an incorrect username';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT username_success;

SAVEPOINT username_incorrect;
DO $$
DECLARE
  _session vibetype.session;

BEGIN
  PERFORM vibetype_test.account_registration_verified ('username', 'email@example.com');

  BEGIN
    _session := vibetype.session_create('username_incorrect', 'password');
  EXCEPTION WHEN no_data_found THEN
    NULL;
  END;
END $$;
ROLLBACK TO SAVEPOINT username_incorrect;

SAVEPOINT username_password_incorrect;
DO $$
DECLARE
  _session vibetype.session;
BEGIN
  PERFORM vibetype_test.account_registration_verified ('username', 'email@example.com');

  BEGIN
    _session := vibetype.session_create('username', 'password_incorrect');
  EXCEPTION WHEN no_data_found THEN
    NULL;
  END;

  IF _session IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: Authentication should not have returned a session';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT username_password_incorrect;

SAVEPOINT email_success;
DO $$
DECLARE
  _session vibetype.session;
BEGIN
  PERFORM vibetype_test.account_registration_verified ('username', 'email@example.com');
  _session := vibetype.session_create('email@example.com', 'password');

  IF _session IS NULL THEN
    RAISE EXCEPTION 'Test failed: Authentication should have returned a session';
  END IF;

  IF _session.account_username <> 'username' THEN
    RAISE EXCEPTION 'Test failed: session contains an incorrect user name';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT email_success;

SAVEPOINT email_incorrect;
DO $$
DECLARE
  _session vibetype.session;
BEGIN
  PERFORM vibetype_test.account_registration_verified ('username', 'email@example.com');

  BEGIN
    _session := vibetype.session_create('email_incorrect@example.com', 'password');
  EXCEPTION WHEN no_data_found THEN
    NULL;
  END;

  IF _session IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: Authentication should not have returned a session';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT email_incorrect;

SAVEPOINT email_password_incorrect;
DO $$
DECLARE
  _session vibetype.session;
BEGIN
  PERFORM vibetype_test.account_registration_verified ('username', 'email@example.com');

  BEGIN
    _session := vibetype.session_create('email@example.com', 'password_incorrect');
  EXCEPTION WHEN no_data_found THEN
    NULL;
  END;

  IF _session IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: Authentication should not have returned a session';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT email_password_incorrect;

ROLLBACK;
