\echo test_friendship..

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
  -- before all
  accountA := vibetype_test.account_registration_verified('username-a', 'email+a@example.com');
  accountB := vibetype_test.account_registration_verified('username-b', 'email+b@example.com');
  accountC := vibetype_test.account_registration_verified('username-c', 'email+c@example.com');

  -- friendship request from user A to B
  friendshipAB := vibetype_test.friendship_request(accountA, accountB);
  PERFORM vibetype_test.friendship_test('The friendship is requested for user A', accountA, 'requested', ARRAY[friendshipAB]::UUID[]);
  PERFORM vibetype_test.friendship_test('The friendship is requested for user B', accountB, 'requested', ARRAY[friendshipAB]::UUID[]);
  PERFORM vibetype_test.friendship_account_ids_test('User A has no friends', accountA, ARRAY[]::UUID[]);
  PERFORM vibetype_test.friendship_account_ids_test('User B has no friends', accountB, ARRAY[]::UUID[]);

  -- friendship acceptance
  PERFORM vibetype_test.friendship_accept(accountB, friendshipAB);
  PERFORM vibetype_test.friendship_test('The friendship is accepted for user A', accountA, 'accepted', ARRAY[friendshipAB]::UUID[]);
  PERFORM vibetype_test.friendship_test('The friendship is accepted for user B', accountB, 'accepted', ARRAY[friendshipAB]::UUID[]);
  PERFORM vibetype_test.friendship_test('There is no requested friendship for user A', accountA, 'requested', ARRAY[]::UUID[]);
  PERFORM vibetype_test.friendship_test('There is no requested friendship for user B', accountA, 'requested', ARRAY[]::UUID[]);
  PERFORM vibetype_test.friendship_account_ids_test('User B is a friend of user A', accountA, ARRAY[accountB]::UUID[]);
  PERFORM vibetype_test.friendship_account_ids_test('User A is a friend of user B', accountB, ARRAY[accountA]::UUID[]);

  -- friendship request from user C to A
  friendshipCA := vibetype_test.friendship_request(accountC, accountA);
  PERFORM vibetype_test.friendship_test('There is still only one accepted friendship for user A', accountA, 'accepted', ARRAY[friendshipAB]::UUID[]);
  PERFORM vibetype_test.friendship_test('There is a new requested friendship for user C', accountC, 'requested', ARRAY[friendshipCA]::UUID[]);
  PERFORM vibetype_test.friendship_account_ids_test('User B is still a friend of user A', accountA, ARRAY[accountB]::UUID[]);
  PERFORM vibetype_test.friendship_account_ids_test('User C has no friends', accountC, ARRAY[]::UUID[]);

  BEGIN
    friendshipAC := vibetype_test.friendship_request(accountA, accountC);
    RAISE 'It was possible to requested a friendship more than once.';
  EXCEPTION
    WHEN unique_violation THEN -- do nothing as expected
    WHEN OTHERS THEN RAISE;
  END;

  -- friendship rejection
  PERFORM vibetype_test.friendship_reject(accountA, friendshipCA);
  PERFORM vibetype_test.friendship_test('After user A rejected user C''s friendship request, the friendship is removed for user C', accountC, NULL, ARRAY[]::UUID[]);
  PERFORM vibetype_test.friendship_account_ids_test('After user A rejected user C''s friendship request, user B is still a friend of user A', accountA, ARRAY[accountB]::UUID[]);
  PERFORM vibetype_test.friendship_account_ids_test('After user A rejected user C''s friendship request, user C has no friends anymore', accountC, ARRAY[]::UUID[]);
END $$;

ROLLBACK;
