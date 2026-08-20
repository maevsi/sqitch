\echo test_account_password_reset_request...

BEGIN;

SAVEPOINT function_privileges_for_roles;
DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.account_password_reset_request(TEXT, TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test function_privileges_for_roles failed: vibetype_account does not have EXECUTE privilege';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.account_password_reset_request(TEXT, TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test function_privileges_for_roles failed: vibetype_anonymous does not have EXECUTE privilege';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT function_privileges_for_roles;

SAVEPOINT account_password_reset_request;
DO $$
BEGIN
  PERFORM vibetype_test.account_registration_verified('username', 'email@example.com');
  PERFORM vibetype.account_password_reset_request('email@example.com', 'en', 'Europe/Berlin');

  IF vibetype_test.account_password_reset_verification_get('email@example.com') IS NULL THEN
    RAISE EXCEPTION 'Test failed: password reset verification not set';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT account_password_reset_request;

SAVEPOINT time_zone_omitted;
DO $$
BEGIN
  PERFORM vibetype_test.account_registration_verified('username', 'email@example.com');
  PERFORM vibetype.account_password_reset_request('email@example.com', 'en');

  IF vibetype_test.account_password_reset_verification_get('email@example.com') IS NULL THEN
    RAISE EXCEPTION 'Test failed: password reset verification not set when the time zone is omitted';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT time_zone_omitted;

SAVEPOINT time_zone_explicit_null;
DO $$
BEGIN
  PERFORM vibetype_test.account_registration_verified('username', 'email@example.com');
  PERFORM vibetype.account_password_reset_request('email@example.com', 'en', NULL);

  IF vibetype_test.account_password_reset_verification_get('email@example.com') IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: password reset verification set despite an explicit NULL time zone (function is STRICT)';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT time_zone_explicit_null;

SAVEPOINT unknown_email_address;
DO $$
BEGIN
  PERFORM vibetype.account_password_reset_request('unknown@example.com', 'en');
END $$;
ROLLBACK TO SAVEPOINT unknown_email_address;

ROLLBACK;
