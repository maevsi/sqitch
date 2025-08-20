\echo test_friendship...

BEGIN;

DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  rec RECORD;
  _is_close_friend BOOLEAN;
  _invoker_account_id UUID;
BEGIN
  -- create accounts
  accountA := vibetype_test.account_registration_verified('username-a', 'email+a@example.com');
  accountB := vibetype_test.account_registration_verified('username-b', 'email+b@example.com');
  accountC := vibetype_test.account_registration_verified('username-c', 'email+c@example.com');

  PERFORM vibetype_test.friendship_request_test('before A sends request to B', accountA, accountA, accountB, false);

  -- friendship request from user A to B
  PERFORM vibetype_test.friendship_request(accountA, accountB);

  PERFORM vibetype_test.friendship_request_test('after A sends request to B (1)', accountA, accountA, accountB, true);
  PERFORM vibetype_test.friendship_request_test('after A sends request to B (2)', accountB, accountA, accountB, true);
  PERFORM vibetype_test.friendship_test('after A sends request to B (3)', accountA, accountA, accountB, false);
  PERFORM vibetype_test.friendship_test('after A sends request to B (4)', accountB, accountB, accountA, false);
  PERFORM vibetype_test.friendship_request_test('C cannot seen the friendship request from A to B', accountC, accountA, accountB, false);

  -- B accepts A's friendship request
  PERFORM vibetype_test.friendship_accept(accountB, accountA);

  PERFORM vibetype_test.friendship_request_test('B accepts friendship request from A (1)', accountA, accountA, accountB, false);
  PERFORM vibetype_test.friendship_test('B accepts friendship request from A (2)', accountA, accountA, accountB, true);
  PERFORM vibetype_test.friendship_test('B accepts friendship request from A (3)', accountB, accountB, accountA, true);
  PERFORM vibetype_test.friendship_test('C can also see the friendship between A and B (1)', accountC, accountA, accountB, true);
  PERFORM vibetype_test.friendship_test('C can also see the friendship between A and B (2)', accountC, accountB, accountA, true);

  -- friendship request from user C to A
  PERFORM vibetype_test.friendship_request(accountC, accountA);

  PERFORM vibetype_test.friendship_request_test('after C sends request to A (1)', accountC, accountC, accountA, true);
  PERFORM vibetype_test.friendship_test('after C sends request to A (2)', accountC, accountC, accountA, false);
  PERFORM vibetype_test.friendship_test('after A sends request to B (3)', accountA, accountA, accountC, false);
  PERFORM vibetype_test.friendship_test('User B is still a friend of user A (1)', accountA, accountA, accountB, true);
  PERFORM vibetype_test.friendship_test('User A is still a friend of user B (2)', accountB, accountB, accountA, true);
  PERFORM vibetype_test.friendship_test('User C is not a friend of A', accountC, accountC, accountA, false);
  PERFORM vibetype_test.friendship_test('User C is not a friend of B', accountC, accountC, accountA, false);
  BEGIN
    -- C sends another request to A, should lead to exception VTREQ
    PERFORM vibetype_test.friendship_request(accountA, accountC);
    RAISE 'C sends another request to A: it was possible to request a friendship more than once.';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLSTATE != 'VTREQ' THEN
        RAISE;
      END IF;
  END;

  BEGIN
    -- A sends a request to C, should lead to exception VTREQ
    PERFORM vibetype_test.friendship_request(accountA, accountC);
    RAISE 'A sends a request to C: it was possible to request a friendship more than once.';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLSTATE != 'VTREQ' THEN
        RAISE;
      END IF;
  END;

  BEGIN
    -- A sends a new request to B, should lead to exception VTFEX
    PERFORM vibetype_test.friendship_request(accountA, accountB);
    RAISE 'A sends a new request to B: it was possible to request for an already existing friendship.';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLSTATE != 'VTFEX' THEN
        RAISE;
      END IF;
  END;

  BEGIN
    -- B sends a new request to A, should lead to exception VTFEX
    PERFORM vibetype_test.friendship_request(accountB, accountA);
    RAISE 'It was possible to request for an already existing friendship.';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLSTATE != 'VTFEX' THEN
        RAISE;
      END IF;
  END;

  -- A rejects friendship request from C
  PERFORM vibetype_test.friendship_reject(accountA, accountC);
  PERFORM vibetype_test.friendship_test('After A rejected C''s friendship request (1)', accountA, accountC, accountA, false);
  PERFORM vibetype_test.friendship_test('After A rejected C''s friendship request (2)', accountC, accountC, accountA, false);

  -- a new friendship request from user C to A, this time accepted by A
  PERFORM vibetype_test.friendship_request(accountC, accountA);
  PERFORM vibetype_test.friendship_accept(accountA, accountC);
  PERFORM vibetype_test.friendship_test('C is a friend of A (1)', accountA, accountA, accountC, true);
  PERFORM vibetype_test.friendship_test('C is a friend of A (2)', accountA, accountC, accountA, true);
  PERFORM vibetype_test.friendship_test('C is a friend of A (3)', accountC, accountA, accountC, true);
  PERFORM vibetype_test.friendship_test('C is a friend of A (4)', accountC, accountC, accountA, true);

  -- friendship request from user B to C
  PERFORM vibetype_test.friendship_request(accountB, accountC);

  -- B marks A as a close friend
  PERFORM vibetype_test.friendship_toggle_closeness(accountB, accountA);

/*
  RAISE NOTICE '----';
  FOR rec IN
    SELECT a.username, b.username as friend_username, f.is_close_friend
    FROM vibetype.friendship f
      JOIN vibetype.account a ON f.account_id = a.id
      JOIN vibetype.account b ON f.friend_account_id = b.id
  LOOP
	RAISE NOTICE 'friendship: account = %, friend_account = %, is_close_friend = %', rec.username, rec.friend_username, rec.is_close_friend;
  END LOOP;
*/

  -- Test: closeness is also visible for the account that declared or cancelled this property
  -- towards one of the account's friends

  PERFORM vibetype_test.friendship_closeness_test('B marks A as a close friend (1)', accountB, accountB, accountA, true);
  PERFORM vibetype_test.friendship_closeness_test('B marks A as a close friend (2)', accountB, accountA, accountB, null);
  PERFORM vibetype_test.friendship_closeness_test('B marks A as a close friend (3)', accountA, accountB, accountA, null);
  PERFORM vibetype_test.friendship_closeness_test('B marks A as a close friend (4)', accountA, accountA, accountB, false);
  PERFORM vibetype_test.friendship_closeness_test('B marks A as a close friend (5)', accountC, accountB, accountA, null);
  PERFORM vibetype_test.friendship_closeness_test('B marks A as a close friend (6)', accountC, accountA, accountB, null);

  -- A marks B as a close friend
  PERFORM vibetype_test.friendship_toggle_closeness(accountA, accountB);

  PERFORM vibetype_test.friendship_closeness_test('A marks B as a close friend (1)', accountB, accountB, accountA, true);
  PERFORM vibetype_test.friendship_closeness_test('A marks B as a close friend (2)', accountB, accountA, accountB, null);
  PERFORM vibetype_test.friendship_closeness_test('A marks B as a close friend (3)', accountA, accountB, accountA, null);
  PERFORM vibetype_test.friendship_closeness_test('A marks B as a close friend (4)', accountA, accountA, accountB, true);
  PERFORM vibetype_test.friendship_closeness_test('B marks A as a close friend (5)', accountC, accountB, accountA, null);
  PERFORM vibetype_test.friendship_closeness_test('B marks A as a close friend (6)', accountC, accountA, accountB, null);

  -- B unmarks A as a close friend
  PERFORM vibetype_test.friendship_toggle_closeness(accountB, accountA);

  PERFORM vibetype_test.friendship_closeness_test('B unmarks A as a close friend (1)', accountB, accountB, accountA, false);
  PERFORM vibetype_test.friendship_closeness_test('B unmarks A as a close friend (2)', accountB, accountA, accountB, null);
  PERFORM vibetype_test.friendship_closeness_test('B unmarks A as a close friend (3)', accountA, accountB, accountA, null);
  PERFORM vibetype_test.friendship_closeness_test('B unmarks A as a close friend (4)', accountA, accountA, accountB, true);
  PERFORM vibetype_test.friendship_closeness_test('B marks A as a close friend (5)', accountC, accountB, accountA, null);
  PERFORM vibetype_test.friendship_closeness_test('B marks A as a close friend (6)', accountC, accountA, accountB, null);

END $$;

ROLLBACK;
