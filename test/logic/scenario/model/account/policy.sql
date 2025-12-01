\echo test_account/policy...

BEGIN;

SAVEPOINT account_select;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.account_test('unblocked account visible to user', accountA, accountB, true);
END $$;
ROLLBACK TO SAVEPOINT account_select;

SAVEPOINT account_select_block_blocker;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.account_block_create(accountA, accountB);

  PERFORM vibetype_test.account_test('blocked account not visible to blocker', accountA, accountB, false);
END $$;
ROLLBACK TO SAVEPOINT account_select_block_blocker;

SAVEPOINT account_select_block_blocked;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.account_block_create(accountA, accountB);

  PERFORM vibetype_test.account_test('blocker not visible to blocked account', accountB, accountA, false);
END $$;
ROLLBACK TO SAVEPOINT account_select_block_blocked;

ROLLBACK;
