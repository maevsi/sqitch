\echo test_close_friend...

BEGIN;

SAVEPOINT close_friend_mark;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  friendshipAB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  friendshipAB := vibetype_test.friendship_create_accepted(accountA, accountB);

  PERFORM vibetype_test.invoker_set(accountA);
  INSERT INTO vibetype.close_friend(friendship_id, created_by) VALUES (friendshipAB, accountA);
  ASSERT (SELECT count(*) FROM vibetype.close_friend) = 1, 'Test failed: the marking account does not see its marking';

  BEGIN
    INSERT INTO vibetype.close_friend(friendship_id, created_by) VALUES (friendshipAB, accountA);
    RAISE EXCEPTION 'Test failed: a friend could be marked as close twice';
  EXCEPTION WHEN unique_violation THEN
    NULL;
  END;

  PERFORM vibetype_test.invoker_set(accountB);
  ASSERT (SELECT count(*) FROM vibetype.close_friend) = 0, 'Test failed: the friend sees the marking';
  DELETE FROM vibetype.close_friend WHERE friendship_id = friendshipAB;
  INSERT INTO vibetype.close_friend(friendship_id, created_by) VALUES (friendshipAB, accountB);
  ASSERT (SELECT count(*) FROM vibetype.close_friend) = 1, 'Test failed: the friend could not mark independently';

  PERFORM vibetype_test.invoker_set(accountC);
  ASSERT (SELECT count(*) FROM vibetype.close_friend) = 0, 'Test failed: another account sees the markings';

  PERFORM vibetype_test.invoker_set(accountA);
  ASSERT (SELECT count(*) FROM vibetype.close_friend) = 1, 'Test failed: the friend could delete the marking';
  DELETE FROM vibetype.close_friend WHERE friendship_id = friendshipAB;
  ASSERT (SELECT count(*) FROM vibetype.close_friend) = 0, 'Test failed: the marking account could not unmark';

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT close_friend_mark;

SAVEPOINT close_friend_forged;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  friendshipAB UUID;
  friendshipAC UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  friendshipAB := vibetype_test.friendship_create_accepted(accountA, accountB);
  friendshipAC := vibetype_test.friendship_create(accountA, accountC);

  PERFORM vibetype_test.invoker_set(accountC);

  BEGIN
    INSERT INTO vibetype.close_friend(friendship_id, created_by) VALUES (friendshipAB, accountC);
    RAISE EXCEPTION 'Test failed: a friendship of other accounts could be marked';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  BEGIN
    INSERT INTO vibetype.close_friend(friendship_id, created_by) VALUES (friendshipAC, accountC);
    RAISE EXCEPTION 'Test failed: a requested friendship could be marked';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    INSERT INTO vibetype.close_friend(friendship_id, created_by) VALUES (friendshipAB, accountB);
    RAISE EXCEPTION 'Test failed: a marking could be created in the name of the friend';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  PERFORM vibetype_test.invoker_set_previous();
  PERFORM vibetype_test.account_block_create(accountB, accountA);
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    INSERT INTO vibetype.close_friend(friendship_id, created_by) VALUES (friendshipAB, accountA);
    RAISE EXCEPTION 'Test failed: a friend involved in a block could be marked';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT close_friend_forged;

SAVEPOINT close_friend_friendship_end;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  friendshipAB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  friendshipAB := vibetype_test.friendship_create_accepted(accountA, accountB);

  PERFORM vibetype_test.invoker_set(accountA);
  INSERT INTO vibetype.close_friend(friendship_id, created_by) VALUES (friendshipAB, accountA);
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.friendship_delete(accountB, friendshipAB);

  PERFORM vibetype_test.invoker_set(accountA);
  ASSERT (SELECT count(*) FROM vibetype.close_friend) = 0, 'Test failed: the marking outlived the friendship';
  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT close_friend_friendship_end;

ROLLBACK;
