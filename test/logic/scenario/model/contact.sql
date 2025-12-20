\echo test_contact...

BEGIN;

SAVEPOINT contact_create_account;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.contact(created_by, email_address)
    VALUES (accountA, 'b@example.com');
END $$;
ROLLBACK TO SAVEPOINT contact_create_account;

SAVEPOINT contact_create_anonymous;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set_anonymous();

  BEGIN
    INSERT INTO vibetype.contact(created_by, email_address)
      VALUES (accountA, 'b@example.com');
    RAISE EXCEPTION 'Test failed (contact_create_anonymous): account % was able to create a contact while invoker is unset.', accountA;
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT contact_create_anonymous;

SAVEPOINT contact_create_block;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.account_block_create(accountA, accountB);

  BEGIN
    PERFORM vibetype_test.contact_create(accountA, 'b@example.com');
    RAISE EXCEPTION 'Test failed (contact_create_block): account % was able to add blocked account % as a contact', accountA, accountB;
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT contact_create_block;

SAVEPOINT contact_create_duplicate;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  -- First create should succeed
  PERFORM vibetype_test.contact_create(accountA, 'b@example.com');

  -- Second create for the same target should fail (uniqueness or policy rule)
  BEGIN
    PERFORM vibetype_test.contact_create(accountA, 'b@example.com');
    RAISE EXCEPTION 'Test failed (contact_create_duplicate): Duplicate contact insertion did not fail as expected.';
  EXCEPTION
    WHEN unique_violation THEN
      NULL; -- expected
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT contact_create_duplicate;

SAVEPOINT contact_create_self;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  -- A user should not be able to add their own account as a contact
  BEGIN
    PERFORM vibetype_test.contact_create(accountA, 'a@example.com');
    RAISE EXCEPTION 'Test failed (contact_create_self): User was able to add their own email as a contact.';
  EXCEPTION
    WHEN unique_violation THEN
      NULL; -- expected
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT contact_create_self;

SAVEPOINT contact_create_time_zone;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.contact(created_by, time_zone)
    VALUES (accountA, 'Europe/Berlin');
END $$;
ROLLBACK TO SAVEPOINT contact_create_time_zone;

SAVEPOINT contact_create_time_zone_invalid;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    INSERT INTO vibetype.contact(created_by, time_zone)
      VALUES (accountA, 'Invalid/Zone');
  EXCEPTION
    WHEN raise_exception THEN
      NULL; -- expected
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT contact_create_time_zone_invalid;

SAVEPOINT contact_select;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactAA UUID;
  contactBB UUID;
  contactAB UUID;
  contactAC UUID;
  contactBA UUID;
  contactBC UUID;
  contactCA UUID;
  contactCB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAA := vibetype_test.contact_select_by_account_id(accountA);
  contactBB := vibetype_test.contact_select_by_account_id(accountB);

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  contactBA := vibetype_test.contact_create(accountB, 'a@example.com');
  contactBC := vibetype_test.contact_create(accountB, 'c@example.com');
  contactCA := vibetype_test.contact_create(accountC, 'a@example.com');
  contactCB := vibetype_test.contact_create(accountC, 'b@example.com');

  -- Sanity: reciprocal contacts should be distinct rows
  IF contactAB = contactBA THEN
    RAISE EXCEPTION 'Test failed (contact_select): reciprocal contacts contactAB and contactBA are identical (%).', contactAB;
  END IF;

  PERFORM vibetype_test.contact_test('contact visibility without block (perspective A)', accountA, ARRAY[contactAA, contactAB, contactAC, contactBA, contactCA]::UUID[]);
  PERFORM vibetype_test.contact_test('contact visibility without block (perspective B)', accountB, ARRAY[contactBB, contactBA, contactBC, contactAB, contactCB]::UUID[]);
END $$;
ROLLBACK TO SAVEPOINT contact_select;

SAVEPOINT contact_select_block;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactAA UUID;
  contactBB UUID;
  contactAB UUID;
  contactAC UUID;
  contactBA UUID;
  contactBC UUID;
  contactCA UUID;
  contactCB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAA := vibetype_test.contact_select_by_account_id(accountA);
  contactBB := vibetype_test.contact_select_by_account_id(accountB);

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  contactBA := vibetype_test.contact_create(accountB, 'a@example.com');
  contactBC := vibetype_test.contact_create(accountB, 'c@example.com');
  contactCA := vibetype_test.contact_create(accountC, 'a@example.com');
  contactCB := vibetype_test.contact_create(accountC, 'b@example.com');

  -- Sanity: reciprocal contacts should be distinct rows
  IF contactAB = contactBA THEN
    RAISE EXCEPTION 'Test failed (contact_select_block): reciprocal contacts contactAB and contactBA are identical (%).', contactAB;
  END IF;

  PERFORM vibetype_test.account_block_create(accountA, accountB);

  PERFORM vibetype_test.contact_test('contact visibility with block (perspective A)', accountA, ARRAY[contactAA, contactAC, contactCA]::UUID[]);
  PERFORM vibetype_test.contact_test('contact visibility with block (perspective B)', accountB, ARRAY[contactBB, contactBC, contactCB]::UUID[]);
END $$;
ROLLBACK TO SAVEPOINT contact_select_block;

SAVEPOINT contact_update_account;
DO $$
DECLARE
  accountA UUID;
  contactAB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  UPDATE vibetype.contact
    SET account_id = NULL
    WHERE id = contactAB;
END $$;
ROLLBACK TO SAVEPOINT contact_update_account;

SAVEPOINT contact_update_anonymous;
DO $$
DECLARE
  accountA UUID;
  contactAB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');

  PERFORM vibetype_test.invoker_set_anonymous();

  BEGIN
    UPDATE vibetype.contact
      SET account_id = NULL
      WHERE id = contactAB;
    RAISE EXCEPTION 'Test failed (contact_update_anonymous): User should not be able to update a contact when invoker is unset.';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT contact_update_anonymous;

SAVEPOINT contact_update_blocked;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  updated_count INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');

  PERFORM vibetype_test.account_block_create(accountA, accountB);
  PERFORM vibetype_test.invoker_set(accountA);

  UPDATE vibetype.contact
    SET first_name = 'Updated'
    WHERE id = contactAB;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  IF updated_count != 0 THEN
    RAISE EXCEPTION 'Test failed (contact_update_blocked): account % updated contact % even though target account % is blocked; updated_count=%', accountA, contactAB, accountB, updated_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_update_blocked;

SAVEPOINT contact_update_other;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactBA UUID;
  updated_count INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactBA := vibetype_test.contact_create(accountB, 'a@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  UPDATE vibetype.contact
    SET first_name = 'Updated'
    WHERE id = contactBA;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  IF updated_count != 0 THEN
    RAISE EXCEPTION 'Test failed (contact_update_other): account % was able to update contact % created by %; updated_count=%', accountA, contactBA, accountB, updated_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_update_other;

SAVEPOINT contact_update_own;
DO $$
DECLARE
  accountA UUID;
  contactAA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  contactAA := vibetype_test.contact_select_by_account_id(accountA);

  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    UPDATE vibetype.contact
      SET account_id = NULL
      WHERE id = contactAA;
    RAISE EXCEPTION 'Test failed (contact_update_own): account % was able to remove its own account association on contact %', accountA, contactAA;
  EXCEPTION
    WHEN foreign_key_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT contact_update_own;

SAVEPOINT contact_delete_account;
DO $$
DECLARE
  accountA UUID;
  contactAB UUID;
  deleted_count INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  DELETE FROM vibetype.contact
    WHERE id = contactAB;

  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  IF deleted_count != 1 THEN
    RAISE EXCEPTION 'Test failed (contact_delete_account): expected deleted_count=1 for contact %, got %', contactAB, deleted_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_delete_account;

SAVEPOINT contact_delete_anonymous;
DO $$
DECLARE
  accountA UUID;
  contactAB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');

  PERFORM vibetype_test.invoker_set_anonymous();

  BEGIN
    DELETE FROM vibetype.contact
      WHERE id = contactAB;
    RAISE EXCEPTION 'Test failed (contact_delete_anonymous): anonymous invoker was able to delete contact % created by %', contactAB, accountA;
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT contact_delete_anonymous;

SAVEPOINT contact_delete_own;
DO $$
DECLARE
  accountA UUID;
  contactAA UUID;
  deleted_count INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  contactAA := vibetype_test.contact_select_by_account_id(accountA);

  PERFORM vibetype_test.invoker_set(accountA);

  DELETE FROM vibetype.contact
    WHERE id = contactAA;

  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  IF deleted_count != 0 THEN
    RAISE EXCEPTION 'Test failed (contact_delete_own): account % was able to delete its own account contact %; deleted_count=%', accountA, contactAA, deleted_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_delete_own;

SAVEPOINT contact_delete_other;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactBA UUID;
  deleted_count INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactBA := vibetype_test.contact_create(accountB, 'a@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  DELETE FROM vibetype.contact
    WHERE id = contactBA;

  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  IF deleted_count != 0 THEN
    RAISE EXCEPTION 'Test failed (contact_delete_other): account % was able to delete contact % created by %; deleted_count=%', accountA, contactBA, accountB, deleted_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_delete_other;

ROLLBACK;
