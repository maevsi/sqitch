\echo test_friendship...

BEGIN;

SAVEPOINT friendship_request;
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

  friendshipAB := vibetype_test.friendship_create(accountA, accountB);

  PERFORM vibetype_test.friendship_test('requester sees the request', accountA, 'requested', ARRAY[friendshipAB]);
  PERFORM vibetype_test.friendship_test('requested account sees the request', accountB, 'requested', ARRAY[friendshipAB]);
  PERFORM vibetype_test.friendship_test('other accounts do not see the request', accountC, NULL, ARRAY[]::UUID[]);
  PERFORM vibetype_test.friendship_test('a request is no friendship yet', accountA, 'accepted', ARRAY[]::UUID[]);
END $$;
ROLLBACK TO SAVEPOINT friendship_request;

SAVEPOINT friendship_request_duplicate;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.friendship_create(accountA, accountB);

  BEGIN
    PERFORM vibetype_test.friendship_create(accountA, accountB);
    RAISE EXCEPTION 'Test failed: the same request could be created twice';
  EXCEPTION WHEN unique_violation THEN
    NULL;
  END;

  BEGIN
    PERFORM vibetype_test.friendship_create(accountB, accountA);
    RAISE EXCEPTION 'Test failed: a request could be answered with a request';
  EXCEPTION WHEN unique_violation THEN
    NULL;
  END;
END $$;
ROLLBACK TO SAVEPOINT friendship_request_duplicate;

SAVEPOINT friendship_request_forged;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    INSERT INTO vibetype.friendship(account_a_id, account_b_id, created_by)
      VALUES (LEAST(accountA, accountB), GREATEST(accountA, accountB), accountB);
    RAISE EXCEPTION 'Test failed: a request could be created in the name of another account';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  BEGIN
    INSERT INTO vibetype.friendship(account_a_id, account_b_id, created_by)
      VALUES (LEAST(accountB, accountC), GREATEST(accountB, accountC), accountA);
    RAISE EXCEPTION 'Test failed: a request could be created between two other accounts';
  EXCEPTION WHEN check_violation OR insufficient_privilege THEN
    NULL;
  END;

  BEGIN
    INSERT INTO vibetype.friendship(account_a_id, account_b_id, created_by, status)
      VALUES (LEAST(accountA, accountB), GREATEST(accountA, accountB), accountA, 'accepted');
    RAISE EXCEPTION 'Test failed: a friendship could be created as accepted';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  BEGIN
    INSERT INTO vibetype.friendship(account_a_id, account_b_id, created_by)
      VALUES (accountA, accountA, accountA);
    RAISE EXCEPTION 'Test failed: an account could befriend itself';
  EXCEPTION WHEN check_violation THEN
    NULL;
  END;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT friendship_request_forged;

SAVEPOINT friendship_accept;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  friendshipAB UUID;
  _friendship vibetype.friendship;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  friendshipAB := vibetype_test.friendship_create(accountA, accountB);

  ASSERT vibetype_test.friendship_accept(accountA, friendshipAB) = 0, 'Test failed: the requester could accept the own request';
  ASSERT vibetype_test.friendship_accept(accountC, friendshipAB) = 0, 'Test failed: another account could accept the request';
  ASSERT vibetype_test.friendship_accept(accountB, friendshipAB) = 1, 'Test failed: the requested account could not accept the request';

  SELECT * INTO _friendship FROM vibetype.friendship WHERE id = friendshipAB;
  ASSERT _friendship.status = 'accepted', 'Test failed: the friendship is not accepted';
  ASSERT _friendship.updated_by = accountB, 'Test failed: the accepting account is not recorded';
  ASSERT _friendship.updated_at IS NOT NULL, 'Test failed: the acceptance time is not recorded';

  PERFORM vibetype_test.friendship_test('requester sees the friendship', accountA, 'accepted', ARRAY[friendshipAB]);
  PERFORM vibetype_test.friendship_test('accepter sees the friendship', accountB, 'accepted', ARRAY[friendshipAB]);
  PERFORM vibetype_test.friendship_test('other accounts see the friendship', accountC, 'accepted', ARRAY[friendshipAB]);
END $$;
ROLLBACK TO SAVEPOINT friendship_accept;

SAVEPOINT friendship_update_forged;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  friendshipAB UUID;
  friendshipCA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  friendshipAB := vibetype_test.friendship_create_accepted(accountA, accountB);
  friendshipCA := vibetype_test.friendship_create(accountC, accountA);

  PERFORM vibetype_test.invoker_set(accountA);

  UPDATE vibetype.friendship SET status = 'requested' WHERE id = friendshipAB;
  ASSERT (SELECT status FROM vibetype.friendship WHERE id = friendshipAB) = 'accepted', 'Test failed: an accepted friendship could be reset to requested';

  BEGIN
    UPDATE vibetype.friendship SET status = 'requested' WHERE id = friendshipCA;
    RAISE EXCEPTION 'Test failed: a request could be updated without accepting it';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  BEGIN
    UPDATE vibetype.friendship SET created_by = accountA WHERE id = friendshipCA;
    RAISE EXCEPTION 'Test failed: the requester could be changed';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  BEGIN
    UPDATE vibetype.friendship SET account_b_id = accountB WHERE id = friendshipCA;
    RAISE EXCEPTION 'Test failed: a participant could be changed';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT friendship_update_forged;

SAVEPOINT friendship_delete;
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

  friendshipAB := vibetype_test.friendship_create(accountA, accountB);
  ASSERT vibetype_test.friendship_delete(accountC, friendshipAB) = 0, 'Test failed: another account could delete the request';
  ASSERT vibetype_test.friendship_delete(accountB, friendshipAB) = 1, 'Test failed: the requested account could not reject the request';
  PERFORM vibetype_test.friendship_test('a rejected request is gone', accountA, NULL, ARRAY[]::UUID[]);

  friendshipAB := vibetype_test.friendship_create(accountA, accountB);
  ASSERT vibetype_test.friendship_delete(accountA, friendshipAB) = 1, 'Test failed: the requester could not withdraw the request';
  PERFORM vibetype_test.friendship_test('a withdrawn request is gone', accountB, NULL, ARRAY[]::UUID[]);

  friendshipAB := vibetype_test.friendship_create_accepted(accountA, accountB);
  ASSERT vibetype_test.friendship_delete(accountC, friendshipAB) = 0, 'Test failed: another account could end the friendship';
  ASSERT vibetype_test.friendship_delete(accountA, friendshipAB) = 1, 'Test failed: the requester could not end the friendship';

  friendshipAB := vibetype_test.friendship_create_accepted(accountA, accountB);
  ASSERT vibetype_test.friendship_delete(accountB, friendshipAB) = 1, 'Test failed: the accepter could not end the friendship';
  PERFORM vibetype_test.friendship_test('an ended friendship is gone', accountA, NULL, ARRAY[]::UUID[]);
END $$;
ROLLBACK TO SAVEPOINT friendship_delete;

SAVEPOINT friendship_block;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  accountD UUID;
  friendshipAB UUID;
  friendshipCA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');
  accountD := vibetype_test.account_registration_verified('d', 'd@example.com');

  friendshipAB := vibetype_test.friendship_create_accepted(accountA, accountB);
  friendshipCA := vibetype_test.friendship_create(accountC, accountA);

  -- a block between the two friends
  PERFORM vibetype_test.account_block_create(accountA, accountB);
  PERFORM vibetype_test.friendship_test('the blocker does not see the friendship', accountA, 'accepted', ARRAY[]::UUID[]);
  PERFORM vibetype_test.friendship_test('the blocked account does not see the friendship', accountB, 'accepted', ARRAY[]::UUID[]);
  PERFORM vibetype_test.friendship_test('other accounts still see the friendship', accountC, 'accepted', ARRAY[friendshipAB]);
  ASSERT vibetype_test.friendship_delete(accountB, friendshipAB) = 0, 'Test failed: a hidden friendship could be ended';
  PERFORM vibetype_test.account_block_delete(accountA, accountB);
  PERFORM vibetype_test.friendship_test('the friendship is back after the unblock', accountB, 'accepted', ARRAY[friendshipAB]);

  -- a block between requester and requested account
  PERFORM vibetype_test.account_block_create(accountA, accountC);
  PERFORM vibetype_test.friendship_test('the blocked requester does not see the request', accountC, 'requested', ARRAY[]::UUID[]);
  ASSERT vibetype_test.friendship_accept(accountA, friendshipCA) = 0, 'Test failed: a hidden request could be accepted';
  PERFORM vibetype_test.account_block_delete(accountA, accountC);
  PERFORM vibetype_test.friendship_test('the request is back after the unblock', accountC, 'requested', ARRAY[friendshipCA]);

  -- a block between a third account and one of the friends
  PERFORM vibetype_test.account_block_create(accountD, accountA);
  PERFORM vibetype_test.friendship_test('the blocker does not see the blocked account''s friendships', accountD, NULL, ARRAY[]::UUID[]);

  BEGIN
    PERFORM vibetype_test.friendship_create(accountA, accountD);
    RAISE EXCEPTION 'Test failed: a blocked account could send a request to its blocker';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  BEGIN
    PERFORM vibetype_test.friendship_create(accountD, accountA);
    RAISE EXCEPTION 'Test failed: a blocker could send a request to the blocked account';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
END $$;
ROLLBACK TO SAVEPOINT friendship_block;

SAVEPOINT friendship_anonymous;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.friendship_create_accepted(accountA, accountB);

  PERFORM vibetype_test.invoker_set_anonymous();

  BEGIN
    PERFORM 1 FROM vibetype.friendship;
    RAISE EXCEPTION 'Test failed: anonymous could read friendships';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT friendship_anonymous;

ROLLBACK;
