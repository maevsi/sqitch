\echo test_account_block_ids...

BEGIN;

SAVEPOINT account_block_ids_blocked;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  blockIds UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  -- Account A blocks account B
  PERFORM vibetype_test.account_block_create(accountA, accountB);

  PERFORM set_config('jwt.claims.account_id', accountA::TEXT, true);

  -- Get block IDs for account A
  blockIds := ARRAY(SELECT id FROM vibetype_private.account_block_ids());

  -- Account A should see account B in block list
  PERFORM vibetype_test.uuid_array_test('blocked account appears in block list', blockIds, ARRAY[accountB]);
END $$;
ROLLBACK TO SAVEPOINT account_block_ids_blocked;

SAVEPOINT account_block_ids_blocker;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  blockIds UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  -- Account A blocks account B
  PERFORM vibetype_test.account_block_create(accountA, accountB);

  PERFORM set_config('jwt.claims.account_id', accountB::TEXT, true);

  -- Get block IDs for account B
  blockIds := ARRAY(SELECT id FROM vibetype_private.account_block_ids());

  -- Account B should see account A (who blocked them) in the list
  PERFORM vibetype_test.uuid_array_test('blocker account appears in blocked user list', blockIds, ARRAY[accountA]);
END $$;
ROLLBACK TO SAVEPOINT account_block_ids_blocker;

SAVEPOINT account_block_ids_mutual;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  blockIds UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  -- Account A blocks account B
  PERFORM vibetype_test.account_block_create(accountA, accountB);
  -- Account B blocks account A
  PERFORM vibetype_test.account_block_create(accountB, accountA);

  PERFORM set_config('jwt.claims.account_id', accountA::TEXT, true);

  -- Get block IDs for account A
  blockIds := ARRAY(SELECT id FROM vibetype_private.account_block_ids());

  -- Account A should see account B (both as blocked and as blocker)
  PERFORM vibetype_test.uuid_array_test('mutual block shows other account', blockIds, ARRAY[accountB]);
END $$;
ROLLBACK TO SAVEPOINT account_block_ids_mutual;

SAVEPOINT account_block_ids_multiple;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  accountD UUID;
  blockIds UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');
  accountD := vibetype_test.account_registration_verified('d', 'd@example.com');

  -- Account A blocks account B and C
  PERFORM vibetype_test.account_block_create(accountA, accountB);
  PERFORM vibetype_test.account_block_create(accountA, accountC);
  -- Account D blocks account A
  PERFORM vibetype_test.account_block_create(accountD, accountA);

  PERFORM set_config('jwt.claims.account_id', accountA::TEXT, true);

  -- Get block IDs for account A
  blockIds := ARRAY(SELECT id FROM vibetype_private.account_block_ids());

  -- Account A should see B, C, and D
  PERFORM vibetype_test.uuid_array_test('multiple blocks show all blocked and blocker accounts', blockIds, ARRAY[accountB, accountC, accountD]);
END $$;
ROLLBACK TO SAVEPOINT account_block_ids_multiple;

ROLLBACK;
