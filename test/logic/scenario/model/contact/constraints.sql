\echo test_contact/constraints...

BEGIN;

-- Test email_address field with exactly 254 characters (boundary), now enforced on
-- vibetype_private.email_address instead of vibetype.contact directly.
SAVEPOINT contact_insert_email_exact_254;
DO $$
DECLARE
  accountA UUID;
  email_254 TEXT := repeat('a', 242) || '@example.com'; -- 242 + 12 = 254
  contact_id UUID;
  email_address_id UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.contact(created_by)
  VALUES (accountA)
  RETURNING id INTO contact_id;

  email_address_id := vibetype_test.email_address_resolve_or_create(email_254);

  INSERT INTO vibetype.contact_email_address(contact_id, email_address_id)
  VALUES (contact_id, email_address_id);

  IF contact_id IS NULL THEN
    RAISE EXCEPTION 'Test failed (contact_insert_email_exact_254): contact not created';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_insert_email_exact_254;

-- Test email_address field with 255 characters (should fail)
SAVEPOINT contact_insert_email_too_long;
DO $$
DECLARE
  email_address_id UUID;
  email_255 TEXT := repeat('a', 243) || '@example.com'; -- 243 + 12 = 255
BEGIN
  BEGIN
    email_address_id := vibetype_test.email_address_resolve_or_create(email_255);
    RAISE EXCEPTION 'Test failed (contact_insert_email_too_long): address with 255 characters accepted';
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

  contact_id := vibetype_test.contact_create(accountA, 'b@example.com');

  UPDATE vibetype.contact SET url = url_2000 WHERE id = contact_id;

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
  contact_id UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  contact_id := vibetype_test.contact_create(accountA, 'b@example.com');

  BEGIN
    UPDATE vibetype.contact SET url = url_2001 WHERE id = contact_id;
    RAISE EXCEPTION 'Test failed (contact_insert_url_too_long): url with 2001 characters accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT contact_insert_url_too_long;

-- Test that a contact without an account_id or an email_address is rejected. The check is now a
-- deferred constraint trigger (it must look up a separate table), so it's forced to run
-- immediately with SET CONSTRAINTS to observe the failure within this statement.
SAVEPOINT contact_insert_identity_missing;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    SET CONSTRAINTS vibetype.contact_identity_check IMMEDIATE;
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

  contact_id := vibetype_test.contact_create(accountA, 'b@example.com');

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

-- Test that account_id IS NULL together with account_deleted alone satisfies the identity
-- constraint, the state left behind by vibetype.account_delete for a peer contact without an
-- email fallback.
SAVEPOINT contact_insert_identity_account_deleted_only;
DO $$
DECLARE
  accountA UUID;
  contact_id UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.contact(created_by, account_deleted)
  VALUES (accountA, TRUE)
  RETURNING id INTO contact_id;

  IF contact_id IS NULL THEN
    RAISE EXCEPTION 'Test failed (contact_insert_identity_account_deleted_only): contact not created';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_insert_identity_account_deleted_only;

-- Test that reassigning a contact_email_address row's contact_id away from a contact that has no
-- account_id and no other email address is rejected, the same way deleting that row already is.
SAVEPOINT contact_email_address_update_identity_missing;
DO $$
DECLARE
  accountA UUID;
  contactA UUID;
  contactB UUID;
  _email_address_id UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  contactA := vibetype_test.contact_create(accountA, 'b@example.com');
  -- contactB has its own, separate email link, so its own identity check is unaffected by this test.
  contactB := vibetype_test.contact_create(accountA, 'c@example.com');

  SELECT email_address_id INTO _email_address_id FROM vibetype.contact_email_address WHERE contact_id = contactA;

  BEGIN
    SET CONSTRAINTS vibetype.contact_identity_check IMMEDIATE;
    -- is_primary is also cleared here so the move doesn't collide with contactB's own primary row.
    UPDATE vibetype.contact_email_address
      SET contact_id = contactB, is_primary = FALSE
      WHERE contact_id = contactA AND email_address_id = _email_address_id;
    RAISE EXCEPTION 'Test failed (contact_email_address_update_identity_missing): reassigning the only email address away from a contact without an account_id was accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT contact_email_address_update_identity_missing;

ROLLBACK;
