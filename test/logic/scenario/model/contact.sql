\echo test_contact...

BEGIN;

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
    RAISE EXCEPTION 'Test failed: User should not be able to add a blocked user as a contact';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT contact_create_block;

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

  PERFORM vibetype_test.account_block_create(accountA, accountB);

  PERFORM vibetype_test.contact_test('contact visibility with block (perspective A)', accountA, ARRAY[contactAA, contactAC, contactCA]::UUID[]);
  PERFORM vibetype_test.contact_test('contact visibility with block (perspective B)', accountB, ARRAY[contactBB, contactBC, contactCB]::UUID[]);
END $$;
ROLLBACK TO SAVEPOINT contact_select_block;

ROLLBACK;
