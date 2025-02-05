BEGIN;

DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;

  friendshipAB UUID;
  friendshipAC UUID;
  friendshipCA UUID;

BEGIN

  -- fill with test data

  accountA := maevsi_test.friendship_account_create('a', 'a@example.com');
  accountB := maevsi_test.friendship_account_create('b', 'b@example.com');
  accountC := maevsi_test.friendship_account_create('c', 'c@example.com');

  RAISE NOTICE 'accountA = %', accountA;
  RAISE NOTICE 'accountB = %', accountB;
  RAISE NOTICE 'accountC = %', accountC;

  -- run tests

  RAISE NOTICE 'test 1';

  friendshipAB := maevsi_test.friendship_request(accountA, accountB);
  RAISE NOTICE 'friendshipAB = %', friendshipAB;

  PERFORM maevsi_test.friendship_test ('1a', accountA, 'pending', ARRAY[friendshipAB]::UUID[]);
  PERFORM maevsi_test.friendship_account_ids_test ('1b', accountA, ARRAY[]::UUID[]);

  PERFORM maevsi_test.friendship_test ('1c', accountB, 'pending', ARRAY[friendshipAB]::UUID[]);
  PERFORM maevsi_test.friendship_account_ids_test ('1d', accountB, ARRAY[]::UUID[]);

  RAISE NOTICE 'test 2';

  PERFORM maevsi_test.friendship_accept(accountB, friendshipAB);

  PERFORM maevsi_test.friendship_test ('2a', accountA, 'accepted', ARRAY[friendshipAB]::UUID[]);
  PERFORM maevsi_test.friendship_account_ids_test ('2b', accountA, ARRAY[accountB]::UUID[]);
  PERFORM maevsi_test.friendship_test ('2c', accountA, 'pending', ARRAY[]::UUID[]);

  RAISE NOTICE 'test 3';

  friendshipCA := maevsi_test.friendship_request(accountC, accountA);
  RAISE NOTICE 'friendshipCA = %', friendshipCA;

  PERFORM maevsi_test.friendship_test ('3a', accountA, 'accepted', ARRAY[friendshipAB]::UUID[]);
  PERFORM maevsi_test.friendship_test ('3b', accountC, 'pending', ARRAY[friendshipCA]::UUID[]);
  PERFORM maevsi_test.friendship_account_ids_test ('3c', accountA, ARRAY[accountB]::UUID[]);
  PERFORM maevsi_test.friendship_account_ids_test ('3d', accountC, ARRAY[]::UUID[]);

  RAISE NOTICE 'test 4';

  PERFORM maevsi_test.friendship_reject(accountA, friendshipCA);

  PERFORM maevsi_test.friendship_test ('4a', accountA, 'accepted', ARRAY[friendshipAB]::UUID[]);
  PERFORM maevsi_test.friendship_test ('4b', accountC, 'rejected', ARRAY[friendshipCA]::UUID[]);
  PERFORM maevsi_test.friendship_account_ids_test ('4c', accountA, ARRAY[accountB]::UUID[]);
  PERFORM maevsi_test.friendship_account_ids_test ('4d', accountC, ARRAY[]::UUID[]);

  RAISE NOTICE 'test 5';

  BEGIN
    friendshipAC := maevsi_test.friendship_request(accountA, accountC);
    RAISE 'friendship request should have failed';
  EXCEPTION
    WHEN unique_violation THEN -- expected exception => do nothing
    WHEN OTHERS THEN RAISE;
  END;

  RAISE NOTICE 'tests ok';

END $$;

ROLLBACK;
