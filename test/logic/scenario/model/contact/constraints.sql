\echo test_contact/constraints...

BEGIN;

-- Test an email address with exactly 254 characters (boundary)
SAVEPOINT contact_insert_email_exact_254;
DO $$
DECLARE
  accountA UUID;
  email_254 TEXT := repeat('a', 242) || '@example.com'; -- 242 + 12 = 254
  contact_id UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.contact(created_by, email_addresses)
  VALUES (accountA, ARRAY[email_254])
  RETURNING id INTO contact_id;

  IF contact_id IS NULL THEN
    RAISE EXCEPTION 'Test failed (contact_insert_email_exact_254): contact not created';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_insert_email_exact_254;

-- Test an email address with 255 characters (should fail)
SAVEPOINT contact_insert_email_too_long;
DO $$
DECLARE
  accountA UUID;
  email_255 TEXT := repeat('a', 243) || '@example.com'; -- 243 + 12 = 255
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    INSERT INTO vibetype.contact(created_by, email_addresses)
    VALUES (accountA, ARRAY[email_255]);
    RAISE EXCEPTION 'Test failed (contact_insert_email_too_long): an email address with 255 characters accepted';
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

  INSERT INTO vibetype.contact(created_by, email_addresses, url)
  VALUES (accountA, ARRAY['b@example.com'], url_2000)
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
    INSERT INTO vibetype.contact(created_by, email_addresses, url)
    VALUES (accountA, ARRAY['b@example.com'], url_2001);
    RAISE EXCEPTION 'Test failed (contact_insert_url_too_long): url with 2001 characters accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT contact_insert_url_too_long;

-- Test that a contact without an account_id, email_addresses or phone_number is rejected
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
    RAISE EXCEPTION 'Test failed (contact_insert_identity_missing): contact without account_id, email_addresses or phone_number accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT contact_insert_identity_missing;

-- Test that email_addresses alone satisfies the identity constraint
SAVEPOINT contact_insert_identity_email_only;
DO $$
DECLARE
  accountA UUID;
  contact_id UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.contact(created_by, email_addresses)
  VALUES (accountA, ARRAY['b@example.com'])
  RETURNING id INTO contact_id;

  IF contact_id IS NULL THEN
    RAISE EXCEPTION 'Test failed (contact_insert_identity_email_only): contact not created';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_insert_identity_email_only;

-- Test that a phone_number alone satisfies the identity constraint
SAVEPOINT contact_insert_identity_phone_number_only;
DO $$
DECLARE
  accountA UUID;
  contact_id UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.contact(created_by, phone_number)
  VALUES (accountA, '+491234567890')
  RETURNING id INTO contact_id;

  IF contact_id IS NULL THEN
    RAISE EXCEPTION 'Test failed (contact_insert_identity_phone_number_only): contact not created';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_insert_identity_phone_number_only;

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

-- Test that an empty array, a null element and more than 10 email addresses are rejected
SAVEPOINT contact_insert_email_addresses_invalid;
DO $$
DECLARE
  accountA UUID;
  _email_addresses TEXT[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  FOR _email_addresses IN
    SELECT unnest_case FROM (VALUES
      (ARRAY[]::TEXT[]),
      (ARRAY['b@example.com', NULL]),
      (ARRAY(SELECT 'b' || i || '@example.com' FROM generate_series(1, 11) AS i))
    ) AS cases(unnest_case)
  LOOP
    BEGIN
      INSERT INTO vibetype.contact(created_by, email_addresses)
      VALUES (accountA, _email_addresses::vibetype.email_address[]);
      RAISE EXCEPTION 'Test failed (contact_insert_email_addresses_invalid): email addresses % accepted', _email_addresses;
    EXCEPTION
      WHEN check_violation OR not_null_violation THEN
        NULL;
    END;
  END LOOP;
END $$;
ROLLBACK TO SAVEPOINT contact_insert_email_addresses_invalid;

-- Test that 10 email addresses are accepted and that the hash follows the first one
SAVEPOINT contact_insert_email_addresses_primary;
DO $$
DECLARE
  accountA UUID;
  _hash TEXT;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.contact(created_by, email_addresses)
  VALUES (accountA, ARRAY(SELECT ' B' || i || '@Example.com ' FROM generate_series(1, 10) AS i))
  RETURNING email_address_hash INTO _hash;

  IF _hash IS DISTINCT FROM md5('b1@example.com') THEN
    RAISE EXCEPTION 'Test failed (contact_insert_email_addresses_primary): hash % does not match the first email address', _hash;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_insert_email_addresses_primary;

ROLLBACK;
