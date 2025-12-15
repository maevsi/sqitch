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

ROLLBACK;
