\echo test_contact/constraints...

BEGIN;

-- Test email_address field with exactly 254 characters (boundary)
SAVEPOINT contact_insert_email_exact_254;
DO $$
DECLARE
  accountA UUID;
  email_254 TEXT := repeat('a', 242) || '@example.com'; -- 242 + 12 = 254
  contact_id UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.contact(created_by, email_address)
  VALUES (accountA, email_254)
  RETURNING id INTO contact_id;

  IF contact_id IS NULL THEN
    RAISE EXCEPTION 'Test failed (contact_insert_email_exact_254): contact not created';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_insert_email_exact_254;

-- Test email_address field with 255 characters (should fail)
SAVEPOINT contact_insert_email_too_long;
DO $$
DECLARE
  accountA UUID;
  email_255 TEXT := repeat('a', 243) || '@example.com'; -- 243 + 12 = 255
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    INSERT INTO vibetype.contact(created_by, email_address)
    VALUES (accountA, email_255);
    RAISE EXCEPTION 'Test failed (contact_insert_email_too_long): email_address with 255 characters accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT contact_insert_email_too_long;

-- Test url field with exactly 2000 characters (boundary)
SAVEPOINT contact_insert_url_exact_2000;
DO $$
DECLARE
  accountA UUID;
  url_2000 TEXT := 'https://example.com/' || repeat('a', 1980);
  contact_id UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.contact(created_by, url)
  VALUES (accountA, url_2000)
  RETURNING id INTO contact_id;

  IF contact_id IS NULL THEN
    RAISE EXCEPTION 'Test failed (contact_insert_url_exact_2000): contact not created';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_insert_url_exact_2000;

-- Test url field with 2001 characters (should fail)
SAVEPOINT contact_insert_url_too_long;
DO $$
DECLARE
  accountA UUID;
  url_2001 TEXT := 'https://example.com/' || repeat('a', 1981);
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    INSERT INTO vibetype.contact(created_by, url)
    VALUES (accountA, url_2001);
    RAISE EXCEPTION 'Test failed (contact_insert_url_too_long): url with 2001 characters accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT contact_insert_url_too_long;

-- Test that a contact without an account_id or an email_address is rejected
SAVEPOINT contact_insert_identity_missing;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    INSERT INTO vibetype.contact(created_by, first_name)
    VALUES (accountA, 'Jane');
    RAISE EXCEPTION 'Test failed (contact_insert_identity_missing): contact without account_id or email_address accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT contact_insert_identity_missing;

-- Test that an email_address alone satisfies the identity constraint
SAVEPOINT contact_insert_identity_email_only;
DO $$
DECLARE
  accountA UUID;
  contact_id UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.contact(created_by, email_address)
  VALUES (accountA, 'b@example.com')
  RETURNING id INTO contact_id;

  IF contact_id IS NULL THEN
    RAISE EXCEPTION 'Test failed (contact_insert_identity_email_only): contact not created';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_insert_identity_email_only;

-- Test that an account_id alone satisfies the identity constraint
SAVEPOINT contact_insert_identity_account_only;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contact_id UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.contact(created_by, account_id)
  VALUES (accountA, accountB)
  RETURNING id INTO contact_id;

  IF contact_id IS NULL THEN
    RAISE EXCEPTION 'Test failed (contact_insert_identity_account_only): contact not created';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_insert_identity_account_only;

ROLLBACK;
