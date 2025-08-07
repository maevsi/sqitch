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

  PERFORM vibetype_test.friendship_request_test('before A sends request to B', accountA, accountB, false);

  -- friendship request from user A to B
  PERFORM vibetype_test.friendship_request(accountA, accountB, 'de');

  PERFORM vibetype_test.friendship_request_test('after A sends request to B (1)', accountA, accountB, true);
  PERFORM vibetype_test.friendship_test('after A sends request to B (2)', accountA, accountB, null, 0);
  PERFORM vibetype_test.friendship_test('after A sends request to B (3)', accountB, accountA, null, 0);

  -- B accepts A's friendship request
  PERFORM vibetype_test.friendship_accept(accountB, accountA);

  PERFORM vibetype_test.friendship_request_test('B accepts friendship request from A (1)', accountA, accountB, false);
  PERFORM vibetype_test.friendship_test('B accepts friendship request from A (2)', accountA, accountB, false, 1);
  PERFORM vibetype_test.friendship_test('B accepts friendship request from A (3)', accountB, accountA, false, 1);

  -- friendship request from user C to A
  PERFORM vibetype_test.friendship_request(accountC, accountA, 'de');

  PERFORM vibetype_test.friendship_request_test('after C sends request to A (1)', accountC, accountA, true);
  PERFORM vibetype_test.friendship_test('after C sends request to A (2)', accountC, accountA, null, 0);
  PERFORM vibetype_test.friendship_test('after A sends request to B (3)', accountA, accountC, null, 0);
  PERFORM vibetype_test.friendship_test('User B is still a friend of user A (1)', accountA, accountB, null, 1);
  PERFORM vibetype_test.friendship_test('User A is still a friend of user B (2)', accountB, accountA, null, 1);
  PERFORM vibetype_test.friendship_test('User C has no friends', accountC, null, null, 0);

  BEGIN
    -- C sends another request to A, should lead to exception VTREQ
    PERFORM vibetype_test.friendship_request(accountA, accountC, 'de');
    RAISE 'C sends another request to A: it was possible to request a friendship more than once.';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLSTATE != 'VTREQ' THEN
        RAISE;
      END IF;
  END;

  BEGIN
    -- A sends a request to C, should lead to exception VTREQ
    PERFORM vibetype_test.friendship_request(accountA, accountC, 'de');
    RAISE 'A sends a request to C: it was possible to request a friendship more than once.';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLSTATE != 'VTREQ' THEN
        RAISE;
      END IF;
  END;

  BEGIN
    -- A sends a new request to B, should lead to exception VTFEX
    PERFORM vibetype_test.friendship_request(accountA, accountB, 'de');
    RAISE 'A sends a new request to B: it was possible to request for an already existing friendship.';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLSTATE != 'VTFEX' THEN
        RAISE;
      END IF;
  END;

  BEGIN
    -- B sends a new request to A, should lead to exception VTFEX
    PERFORM vibetype_test.friendship_request(accountB, accountA, 'de');
    RAISE 'It was possible to request for an already existing friendship.';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLSTATE != 'VTFEX' THEN
        RAISE;
      END IF;
  END;

  -- A rejects friendship request from C
  PERFORM vibetype_test.friendship_reject(accountA, accountC);
  PERFORM vibetype_test.friendship_test('After A rejected C''s friendship request (1)', accountC, accountA, null, 0);
  PERFORM vibetype_test.friendship_test('After A rejected C''s friendship request (2)', accountA, accountC, null, 0);

  -- a new friendship request from user C to A, this time accepted by A
  PERFORM vibetype_test.friendship_request(accountC, accountA, 'de');
  PERFORM vibetype_test.friendship_accept(accountA, accountC);
  PERFORM vibetype_test.friendship_test('Count the number of A''s friends', accountA, null, null, 2);
  PERFORM vibetype_test.friendship_test('C is a friend of A (1)', accountA, accountC, null, 1);
  PERFORM vibetype_test.friendship_test('C is a friend of A (2)', accountC, accountA, null, 1);

  -- friendship request from user B to A
  PERFORM vibetype_test.friendship_request(accountB, accountC, 'de');


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

  PERFORM vibetype_test.friendship_test('B marks A as a close friend (1)', accountB, accountA, true, 1);
  PERFORM vibetype_test.friendship_test('B marks A as a close friend (2)', accountA, accountB, false, 1);

  -- B unmarks A as a close friend
  PERFORM vibetype_test.friendship_toggle_closeness(accountB, accountA);
  PERFORM vibetype_test.friendship_test('B marks A as a close friend (1)', accountB, accountA, false, 1);

  -- C marks A as a close friend
  PERFORM vibetype_test.friendship_toggle_closeness(accountC, accountA);

  -- A wants to find out, if A is a close friend of C. The result should be NULL.

  SET LOCAL role = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || accountA || '''';

  SELECT is_close_friend INTO _is_close_friend
  FROM vibetype.friendship
  WHERE account_id = accountC and friend_account_id = accountA;

  IF _is_close_friend IS NOT NULL THEN
  	RAISE EXCEPTION 'Closeness should not be disclosed to A.';
  END IF;

  SET LOCAL ROLE NONE;

END $$;

ROLLBACK;
