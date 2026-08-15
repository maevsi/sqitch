\echo test_account_registration...

BEGIN;

SAVEPOINT function_privileges_for_roles;
DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.email_address_verification_request(TEXT, TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test function_privileges_for_roles failed: vibetype_account does not have EXECUTE privilege on email_address_verification_request';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.email_address_verification_request(TEXT, TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test function_privileges_for_roles failed: vibetype_anonymous does not have EXECUTE privilege on email_address_verification_request';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.email_address_verification(UUID)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test function_privileges_for_roles failed: vibetype_anonymous does not have EXECUTE privilege on email_address_verification';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.account_registration(UUID, DATE, UUID, TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test function_privileges_for_roles failed: vibetype_account does not have EXECUTE privilege on account_registration';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.account_registration(UUID, DATE, UUID, TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test function_privileges_for_roles failed: vibetype_anonymous does not have EXECUTE privilege on account_registration';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT function_privileges_for_roles;

SAVEPOINT account_registration;
DO $$
DECLARE
  _legal_term_id UUID;
  _verification_id UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  _verification_id := vibetype_test.email_address_verification_confirmed('email@example.com', 'en', 'UTC');
  PERFORM vibetype.account_registration(_verification_id, '1970-01-01', _legal_term_id, 'password', 'username');
END $$;
ROLLBACK TO SAVEPOINT account_registration;

SAVEPOINT registration_requires_confirmation;
DO $$
DECLARE
  _legal_term_id UUID;
  _unconfirmed_id UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  _unconfirmed_id := vibetype_test.email_address_verification_pending('email@example.com', 'en', 'UTC');

  PERFORM vibetype.account_registration(_unconfirmed_id, '1970-01-01', _legal_term_id, 'password', 'username');
  RAISE EXCEPTION 'Test failed: registration completed with an unconfirmed email address verification';
EXCEPTION WHEN SQLSTATE 'P0002' THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT registration_requires_confirmation;

SAVEPOINT birth_date_age;
DO $$
DECLARE
  _legal_term_id UUID;
  _verification_id UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  _verification_id := vibetype_test.email_address_verification_confirmed('email@example.com', 'en', 'UTC');
  PERFORM vibetype.account_registration(_verification_id, CURRENT_DATE, _legal_term_id, 'password', 'username');
  RAISE EXCEPTION 'Test failed: Birth date age not enforced';
EXCEPTION WHEN SQLSTATE 'VTBDA' THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT birth_date_age;

SAVEPOINT password_length;
DO $$
DECLARE
  _legal_term_id UUID;
  _verification_id UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  _verification_id := vibetype_test.email_address_verification_confirmed('email@example.com', 'en', 'UTC');
  PERFORM vibetype.account_registration(_verification_id, '1970-01-01', _legal_term_id, 'short', 'username');
  RAISE EXCEPTION 'Test failed: Password length not enforced';
EXCEPTION WHEN SQLSTATE 'VTPLL' THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT password_length;

SAVEPOINT username_uniqueness;
DO $$
DECLARE
  _legal_term_id UUID;
  _verification_id_1 UUID;
  _verification_id_2 UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  _verification_id_1 := vibetype_test.email_address_verification_confirmed('diff@example.com', 'en', 'UTC');
  _verification_id_2 := vibetype_test.email_address_verification_confirmed('erent@example.com', 'en', 'UTC');
  PERFORM vibetype.account_registration(_verification_id_1, '1970-01-01', _legal_term_id, 'password', 'username-duplicate');
  PERFORM vibetype.account_registration(_verification_id_2, '1970-01-01', _legal_term_id, 'password', 'username-duplicate');
  RAISE EXCEPTION 'Test failed: Duplicate username not enforced';
EXCEPTION WHEN SQLSTATE 'VTAUV' THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT username_uniqueness;

-- Requesting a verification for an already-registered email address silently no-ops (matching
-- the previous anti-enumeration behavior, now moved from account_registration to this earlier step).
SAVEPOINT email_uniqueness;
DO $$
DECLARE
  _legal_term_id UUID;
  _verification_id UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  _verification_id := vibetype_test.email_address_verification_confirmed('duplicate@example.com', 'en', 'UTC');
  PERFORM vibetype.account_registration(_verification_id, '1970-01-01', _legal_term_id, 'password', 'username-diff');

  PERFORM vibetype.email_address_verification_request('duplicate@example.com', 'en', 'UTC');

  IF vibetype_test.email_address_verification_exists('duplicate@example.com') THEN
    RAISE EXCEPTION 'Test failed: a new verification was issued for an already-registered email address';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT email_uniqueness;

SAVEPOINT username_null;
DO $$
DECLARE
  _legal_term_id UUID;
  _verification_id UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  _verification_id := vibetype_test.email_address_verification_confirmed('email@example.com', 'en', 'UTC');
  PERFORM vibetype.account_registration(_verification_id, '1970-01-01', _legal_term_id, 'password', NULL);
  RAISE EXCEPTION 'Test failed: NULL username allowed';
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT username_null;

SAVEPOINT username_length;
DO $$
DECLARE
  _legal_term_id UUID;
  _verification_id UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  _verification_id := vibetype_test.email_address_verification_confirmed('email@example.com', 'en', 'UTC');
  PERFORM vibetype.account_registration(_verification_id, '1970-01-01', _legal_term_id, 'password', '');
  RAISE EXCEPTION 'Test failed: Empty username allowed';
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT username_length;

SAVEPOINT time_zone;
DO $$
DECLARE
  _legal_term_id UUID;
  _verification_id UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  _verification_id := vibetype_test.email_address_verification_confirmed('email@example.com', 'en', 'Europe/Berlin');
  PERFORM vibetype.account_registration(_verification_id, '1970-01-01', _legal_term_id, 'password', 'username-tz');

  IF NOT EXISTS (SELECT 1 FROM vibetype.account WHERE username = 'username-tz') THEN
    RAISE EXCEPTION 'Test failed: account not created when a time zone is given';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT time_zone;

SAVEPOINT time_zone_omitted;
DO $$
DECLARE
  _legal_term_id UUID;
  _verification_id UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  _verification_id := vibetype_test.email_address_verification_confirmed('email@example.com', 'en');
  PERFORM vibetype.account_registration(_verification_id, '1970-01-01', _legal_term_id, 'password', 'username-no-tz');

  IF NOT EXISTS (SELECT 1 FROM vibetype.account WHERE username = 'username-no-tz') THEN
    RAISE EXCEPTION 'Test failed: account not created when the time zone is omitted';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT time_zone_omitted;

SAVEPOINT time_zone_explicit_null;
DO $$
DECLARE
  _legal_term_id UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  PERFORM vibetype.email_address_verification_request('email@example.com', 'en', NULL);
  RAISE EXCEPTION 'Test failed: verification requested despite an explicit NULL time zone (function is STRICT)';
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT time_zone_explicit_null;

ROLLBACK;
