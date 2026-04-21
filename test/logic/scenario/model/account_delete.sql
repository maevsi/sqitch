\echo test_account_delete...

BEGIN;

-- Account deletion must succeed even when the user's own contact is linked.
SAVEPOINT account_delete_with_own_contact;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  -- own contact is created during registration (account_id = created_by = accountA)

  PERFORM vibetype_test.invoker_set(accountA);
  PERFORM vibetype.account_delete('password');

  IF EXISTS (SELECT 1 FROM vibetype.account WHERE id = accountA) THEN
    RAISE EXCEPTION 'Test failed (account_delete_with_own_contact): account still exists after deletion';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT account_delete_with_own_contact;

-- When an account is deleted, peer contacts linking to it must have account_id set to NULL.
SAVEPOINT account_delete_nullifies_peer_contact;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contact_id UUID;
  remaining_account_id UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  contact_id := vibetype_test.contact_create(accountB, 'a@example.com');

  PERFORM vibetype_test.invoker_set(accountA);
  PERFORM vibetype.account_delete('password');

  PERFORM vibetype_test.invoker_set(accountB);

  SELECT account_id INTO remaining_account_id
  FROM vibetype.contact
  WHERE id = contact_id;

  IF remaining_account_id IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed (account_delete_nullifies_peer_contact): expected account_id = NULL, got %', remaining_account_id;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT account_delete_nullifies_peer_contact;

-- Deleting an account with the wrong password must fail.
SAVEPOINT account_delete_wrong_password;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    PERFORM vibetype.account_delete('wrong_password');
    RAISE EXCEPTION 'Test failed (account_delete_wrong_password): deletion with wrong password was accepted';
  EXCEPTION
    WHEN invalid_password THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT account_delete_wrong_password;

ROLLBACK;
