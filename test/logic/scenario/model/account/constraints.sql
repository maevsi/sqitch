\echo test_account/constraints...

BEGIN;

-- Test description field with exactly 1000 characters (boundary)
SAVEPOINT account_update_description_exact_1000;
DO $$
DECLARE
  accountA UUID;
  updated_count INTEGER;
  description_1000 TEXT := repeat('a', 1000);
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  UPDATE vibetype.account
    SET description = description_1000
    WHERE id = accountA;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  IF updated_count != 1 THEN
    RAISE EXCEPTION 'Test failed (account_update_description_exact_1000): expected updated_count=1, got %', updated_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT account_update_description_exact_1000;

-- Test description field with 1001 characters (should fail)
SAVEPOINT account_update_description_too_long;
DO $$
DECLARE
  accountA UUID;
  description_1001 TEXT := repeat('a', 1001);
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    UPDATE vibetype.account
      SET description = description_1001
      WHERE id = accountA;
    RAISE EXCEPTION 'Test failed (account_update_description_too_long): description with 1001 characters accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT account_update_description_too_long;

-- Test imprint_url field with exactly 2000 characters (boundary)
SAVEPOINT account_update_imprint_url_exact_2000;
DO $$
DECLARE
  accountA UUID;
  updated_count INTEGER;
  url_2000 TEXT := 'https://example.com/' || repeat('a', 1980);
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  UPDATE vibetype.account
    SET imprint_url = url_2000
    WHERE id = accountA;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  IF updated_count != 1 THEN
    RAISE EXCEPTION 'Test failed (account_update_imprint_url_exact_2000): expected updated_count=1, got %', updated_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT account_update_imprint_url_exact_2000;

-- Test imprint_url field with 2001 characters (should fail)
SAVEPOINT account_update_imprint_url_too_long;
DO $$
DECLARE
  accountA UUID;
  url_2001 TEXT := 'https://example.com/' || repeat('a', 1981);
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    UPDATE vibetype.account
      SET imprint_url = url_2001
      WHERE id = accountA;
    RAISE EXCEPTION 'Test failed (account_update_imprint_url_too_long): imprint_url with 2001 characters accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT account_update_imprint_url_too_long;

-- Test username field with exactly 100 characters (boundary)
SAVEPOINT account_create_username_exact_100;
DO $$
DECLARE
  username_100 TEXT := repeat('a', 100);
  email TEXT := 'test-100@example.com';
BEGIN
  PERFORM vibetype_test.account_registration_verified(username_100, email);
END $$;
ROLLBACK TO SAVEPOINT account_create_username_exact_100;

-- Test username field with 101 characters (should fail)
SAVEPOINT account_create_username_too_long;
DO $$
DECLARE
  username_101 TEXT := repeat('a', 101);
  email TEXT := 'test-101@example.com';
BEGIN
  BEGIN
    PERFORM vibetype_test.account_registration_verified(username_101, email);
    RAISE EXCEPTION 'Test failed (account_create_username_too_long): username with 101 characters accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT account_create_username_too_long;

-- Test email_address field with exactly 254 characters (boundary)
SAVEPOINT account_create_email_exact_254;
DO $$
DECLARE
  email_254 TEXT := repeat('a', 242) || '@example.com'; -- 242 + 12 = 254
BEGIN
  PERFORM vibetype_test.account_registration_verified('test254', email_254);
END $$;
ROLLBACK TO SAVEPOINT account_create_email_exact_254;

-- Test email_address field with 255 characters (should fail)
SAVEPOINT account_create_email_too_long;
DO $$
DECLARE
  email_255 TEXT := repeat('a', 243) || '@example.com'; -- 243 + 12 = 255
BEGIN
  BEGIN
    PERFORM vibetype_test.account_registration_verified('test255', email_255);
    RAISE EXCEPTION 'Test failed (account_create_email_too_long): email_address with 255 characters accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT account_create_email_too_long;

ROLLBACK;
