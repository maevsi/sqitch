BEGIN;

SAVEPOINT function_privileges_for_roles;
DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.account_registration(TEXT, TEXT, TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test function_privileges_for_roles failed: maevsi_account does not have EXECUTE privilege';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.account_registration(TEXT, TEXT, TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test function_privileges_for_roles failed: maevsi_anonymous does not have EXECUTE privilege';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT function_privileges_for_roles;

SAVEPOINT account_registration;
DO $$
BEGIN
  PERFORM maevsi.account_registration('username', 'email@example.com', 'password', 'en');
END $$;
ROLLBACK TO SAVEPOINT account_registration;

SAVEPOINT password_length;
DO $$
BEGIN
  PERFORM maevsi.account_registration('username', 'email@example.com', 'short', 'en');
  RAISE EXCEPTION 'Test failed: Password length not enforced';
EXCEPTION WHEN invalid_parameter_value THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT password_length;

SAVEPOINT username_uniqueness;
DO $$
BEGIN
  PERFORM maevsi.account_registration('username-duplicate', 'diff@example.com', 'password', 'en');
  PERFORM maevsi.account_registration('username-duplicate', 'erent@example.com', 'password', 'en');
  RAISE EXCEPTION 'Test failed: Duplicate username not enforced';
EXCEPTION WHEN unique_violation THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT username_uniqueness;

SAVEPOINT email_uniqueness;
DO $$
BEGIN
  PERFORM maevsi.account_registration('username-diff', 'duplicate@example.com', 'password', 'en');
  PERFORM maevsi.account_registration('username-erent', 'duplicate@example.com', 'password', 'en');
  RAISE EXCEPTION 'Test failed: Duplicate email not enforced';
EXCEPTION WHEN unique_violation THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT email_uniqueness;

SAVEPOINT username_null;
DO $$
BEGIN
  PERFORM maevsi.account_registration(NULL, 'email@example.com', 'password', 'en');
  RAISE EXCEPTION 'Test failed: NULL username allowed';
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT username_null;

SAVEPOINT username_length;
DO $$
BEGIN
  PERFORM maevsi.account_registration('', 'email@example.com', 'password', 'en');
  RAISE EXCEPTION 'Test failed: Empty username allowed';
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT username_length;

SAVEPOINT notification;
DO $$
BEGIN
  PERFORM maevsi.account_registration('username-8b973f', 'email@example.com', 'password', 'en');

  IF NOT EXISTS (
    SELECT 1 FROM maevsi.notification
    WHERE channel = 'account_registration'
      AND payload::jsonb -> 'account' ->> 'username' = 'username-8b973f'
  ) THEN
    RAISE EXCEPTION 'Test failed: Notification not generated';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT notification;

ROLLBACK;
