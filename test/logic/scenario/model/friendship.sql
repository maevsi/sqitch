\echo test_friendship..

BEGIN;

DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  rec RECORD;
BEGIN
  -- before all
  accountA := vibetype_test.account_registration_verified('username-a', 'email+a@example.com');
  accountB := vibetype_test.account_registration_verified('username-b', 'email+b@example.com');
  accountC := vibetype_test.account_registration_verified('username-c', 'email+c@example.com');

  -- friendship request from user A to B
  PERFORM vibetype_test.friendship_request(accountA, accountB, 'de');


  RAISE NOTICE '----';
  FOR rec IN
    SELECT a.username, b.username as friend_username, f.is_close_friend, f.status
    FROM vibetype.friendship f
      JOIN vibetype.account a ON f.account_id = a.id
      JOIN vibetype.account b ON f.friend_account_id = b.id
  LOOP
	RAISE NOTICE 'friendship: account = %, friend_account = %, is_close_friend = %, status = %', rec.username, rec.friend_username, rec.is_close_friend, rec.status;
  END LOOP;

  PERFORM vibetype_test.friendship_test('A sends B a friendship request (1)', accountA, accountB, false, 'requested', 1);
  PERFORM vibetype_test.friendship_test('A sends B a friendship request (2)', accountB, accountA, false, 'requested', 0);
  PERFORM vibetype_test.friendship_test('A sends B a friendship request (3)', accountA, accountB, false, null, 1);
  PERFORM vibetype_test.friendship_test('A sends B a friendship request (3)', accountB, accountA, false, null, 0);

  -- B accepts A's friendship request
  PERFORM vibetype_test.friendship_accept(accountB, accountA);

  PERFORM vibetype_test.friendship_test('B accepts friendship request from A (1)', accountA, accountB, false, 'requested', 0);
  PERFORM vibetype_test.friendship_test('B accepts friendship request from A (2)', accountA, accountB, false, 'accepted', 1);
  PERFORM vibetype_test.friendship_test('B accepts friendship request from A (3)', accountB, accountA, false, 'accepted', 1);

  -- friendship request from user C to A
  PERFORM vibetype_test.friendship_request(accountC, accountA, 'de');

  PERFORM vibetype_test.friendship_test('There is still only one accepted friendship for user A', accountA, null, false, 'accepted', 1);
  PERFORM vibetype_test.friendship_test('There is a new requested friendship for user C (1)', accountC, null, false, 'requested', 1);
  PERFORM vibetype_test.friendship_test('There is a new requested friendship for user C (2)', accountA, accountC, false, null, 0);
  PERFORM vibetype_test.friendship_test('User B is still a friend of user A (1)', accountA, accountB, false, null, 1);
  PERFORM vibetype_test.friendship_test('User B is still a friend of user A (2)', accountB, accountA, false, null, 1);
  PERFORM vibetype_test.friendship_test('User C has no friends', accountC, null, false, 'accepted', 0);

  BEGIN
    PERFORM vibetype_test.friendship_request(accountA, accountC, 'de');
    RAISE 'It was possible to request a friendship more than once.';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLSTATE != 'VTREQ' THEN
        RAISE;
      END IF;
  END;

  -- friendship rejection
  PERFORM vibetype_test.friendship_cancel(accountA, accountC);
  PERFORM vibetype_test.friendship_test('After user A rejected user C''s friendship request (1)', accountC, accountA, false, null, 0);
  PERFORM vibetype_test.friendship_test('After user A rejected user C''s friendship request (2)', accountA, accountC, false, null, 0);

  -- a new friendship request from user C to A, this time accepted by A
  PERFORM vibetype_test.friendship_request(accountC, accountA, 'de');
  PERFORM vibetype_test.friendship_accept(accountA, accountC);
  PERFORM vibetype_test.friendship_test('Count the number of A''s friends', accountA, null, false, 'accepted', 2);
  PERFORM vibetype_test.friendship_test('C is a friend of A (1)', accountA, accountC, false, 'accepted', 1);
  PERFORM vibetype_test.friendship_test('C is a friend of A (2)', accountC, accountA,  false, 'accepted', 1);

  -- friendship request from user B to A
  PERFORM vibetype_test.friendship_request(accountB, accountC, 'de');

  BEGIN
    PERFORM vibetype_test.friendship_toggle_closeness(accountB, accountC);
    RAISE 'It was possible to toggle closeness in a friendship request.';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLSTATE != 'VTFTC' THEN
        RAISE;
      END IF;
  END;

  -- B marks A as a close friend
  PERFORM vibetype_test.friendship_toggle_closeness(accountB, accountA);
  PERFORM vibetype_test.friendship_test('B marks A as a close friend (1)', accountB, accountA, true, 'accepted', 1);
  PERFORM vibetype_test.friendship_test('B marks A as a close friend (2)', accountA, accountB, true, NULL, 0);

END $$;

ROLLBACK;
