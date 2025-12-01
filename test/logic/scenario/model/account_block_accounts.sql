\echo test_account_block_accounts...

BEGIN;

SAVEPOINT account_block_accounts_blocked;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.account_block_create(accountA, accountB);

  PERFORM vibetype_test.account_block_accounts_test('blocked account appears in block list', accountA, accountB, true);
END $$;
ROLLBACK TO SAVEPOINT account_block_accounts_blocked;

SAVEPOINT account_block_accounts_blocker;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.account_block_create(accountA, accountB);

  PERFORM vibetype_test.account_block_accounts_test('blocker not in blocked user block list', accountB, accountA, false);
END $$;
ROLLBACK TO SAVEPOINT account_block_accounts_blocker;

ROLLBACK;
