\echo test_account_registration...

BEGIN;

SAVEPOINT function_privileges_for_roles;
DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.account_registration(DATE, TEXT, TEXT, UUID, TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test function_privileges_for_roles failed: vibetype_account does not have EXECUTE privilege';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.account_registration(DATE, TEXT, TEXT, UUID, TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test function_privileges_for_roles failed: vibetype_anonymous does not have EXECUTE privilege';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT function_privileges_for_roles;

SAVEPOINT account_registration;
DO $$
DECLARE
  _legal_term_id UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  PERFORM vibetype.account_registration('1970-01-01', 'email@example.com', 'en', _legal_term_id, 'password', 'username');
END $$;
ROLLBACK TO SAVEPOINT account_registration;

SAVEPOINT birth_date_age;
DO $$
DECLARE
  _legal_term_id UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  PERFORM vibetype.account_registration(CURRENT_DATE, 'email@example.com', 'en', _legal_term_id, 'password', 'username');
  RAISE EXCEPTION 'Test failed: Birth date age not enforced';
EXCEPTION WHEN SQLSTATE 'VTBDA' THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT birth_date_age;

SAVEPOINT password_length;
DO $$
DECLARE
  _legal_term_id UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  PERFORM vibetype.account_registration('1970-01-01', 'email@example.com', 'en', _legal_term_id, 'short', 'username');
  RAISE EXCEPTION 'Test failed: Password length not enforced';
EXCEPTION WHEN SQLSTATE 'VTPLL' THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT password_length;

SAVEPOINT username_uniqueness;
DO $$
DECLARE
  _legal_term_id UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  PERFORM vibetype.account_registration('1970-01-01', 'diff@example.com', 'en', _legal_term_id, 'password', 'username-duplicate');
  PERFORM vibetype.account_registration('1970-01-01', 'erent@example.com', 'en', _legal_term_id, 'password', 'username-duplicate');
  RAISE EXCEPTION 'Test failed: Duplicate username not enforced';
EXCEPTION WHEN SQLSTATE 'VTAUV' THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT username_uniqueness;

SAVEPOINT email_uniqueness;
DO $$
DECLARE
  _legal_term_id UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  PERFORM vibetype.account_registration('1970-01-01', 'duplicate@example.com', 'en', _legal_term_id, 'password', 'username-diff');
  PERFORM vibetype.account_registration('1970-01-01', 'duplicate@example.com', 'en', _legal_term_id, 'password', 'username-erent');
END $$;
ROLLBACK TO SAVEPOINT email_uniqueness;

SAVEPOINT username_null;
DO $$
DECLARE
  _legal_term_id UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  PERFORM vibetype.account_registration('1970-01-01', 'email@example.com', 'en', _legal_term_id, 'password', NULL);
  RAISE EXCEPTION 'Test failed: NULL username allowed';
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT username_null;

SAVEPOINT username_length;
DO $$
DECLARE
  _legal_term_id UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  PERFORM vibetype.account_registration('1970-01-01', 'email@example.com', 'en', _legal_term_id, 'password', '');
  RAISE EXCEPTION 'Test failed: Empty username allowed';
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT username_length;

SAVEPOINT notification;
DO $$
DECLARE
  _legal_term_id UUID;
  _account_id UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  PERFORM vibetype.account_registration('1970-01-01', 'email@example.com', 'en', _legal_term_id, 'password', 'username-8b973f');

  SELECT id INTO _account_id
  FROM vibetype.account
  WHERE username = 'username-8b973f';

  PERFORM vibetype_test.invoker_set(_account_id);

/* TODO: remove comments when PR "feat(notification)!: inherit invitations" has been merged
  IF NOT EXISTS (
    SELECT 1 FROM vibetype.notification
    WHERE channel = 'account_registration'
      AND payload::jsonb -> 'account' ->> 'username' = 'username-8b973f'
  ) THEN
    RAISE EXCEPTION 'Test failed: Notification not generated';
  END IF;
*/

  PERFORM vibetype_test.invoker_set_previous();

END $$;
ROLLBACK TO SAVEPOINT notification;

ROLLBACK;
