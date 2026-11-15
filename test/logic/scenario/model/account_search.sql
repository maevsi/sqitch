BEGIN;

DO $$
DECLARE
  _search_result TEXT[];
  _search_result_expected TEXT[];
  _search_string TEXT;
  _search_strings TEXT[];
  _user_account_id UUID;
  _username TEXT;
  _usernames TEXT[];
BEGIN

  _usernames := ARRAY['abc', 'cdef', 'BcblfGa', 'ffg56H'];

  FOREACH _username IN ARRAY _usernames
  LOOP
    IF _username = 'abc' THEN
       _user_account_id := vibetype_test.account_registration_verified(_username, lower(_username)||'@example.com');
    ELSE
       PERFORM vibetype_test.account_registration_verified(_username, lower(_username)||'@example.com');
    END IF;
  END LOOP;

  PERFORM vibetype_test.invoker_set(_user_account_id);

  _search_strings := ARRAY['A', 'a', 'c', 'f' , 'fg', 'fh'];

  FOREACH _search_string IN ARRAY _search_strings
  LOOP
    -- Sorted alphabetically here since result ORDER is now by trigram similarity (closest match
    -- first, see the dedicated `account_search_order` test below), not alphabetical; this loop only
    -- asserts which accounts match, independent of the order they come back in.
    _search_result := ARRAY(SELECT username FROM vibetype.account_search(_search_string) ORDER BY username);

    _search_result_expected :=
      CASE _search_string
        WHEN 'A' THEN ARRAY['abc', 'BcblfGa']
        WHEN 'a' THEN ARRAY['abc', 'BcblfGa']
        WHEN 'c' THEN ARRAY['abc', 'BcblfGa', 'cdef']
        WHEN 'f' THEN ARRAY['BcblfGa', 'cdef', 'ffg56H']
        WHEN 'fg' THEN ARRAY['BcblfGa', 'ffg56H']
        WHEN 'fh' THEN ARRAY[]::text[]
      END;

    IF _search_result <> _search_result_expected THEN
      RAISE EXCEPTION E'Search for % does not return the expected result.\nExpected: %\nReturned: %', _search_string, _search_result_expected, _search_result;
    END IF;

  END LOOP;

END $$;

SAVEPOINT account_search_order;
DO $$
DECLARE
  _account_close UUID;
  _search_result TEXT[];
BEGIN
  -- An exact match always scores the maximum possible trigram similarity (1.0), so it must rank
  -- first regardless of how many other, looser matches also exist.
  -- 'concerto' and 'disconcert' both contain 'concert' as a substring, so they also match the
  -- ILIKE filter, ensuring the ORDER BY ranking is genuinely exercised rather than trivially
  -- passing because only the exact match was returned.
  _account_close := vibetype_test.account_registration_verified('concert', 'concert@example.com');
  PERFORM vibetype_test.account_registration_verified('concerto', 'concerto@example.com');
  PERFORM vibetype_test.account_registration_verified('disconcert', 'disconcert@example.com');

  PERFORM vibetype_test.invoker_set(_account_close);

  _search_result := ARRAY(SELECT username FROM vibetype.account_search('concert'));

  IF array_length(_search_result, 1) <> 3 THEN
    RAISE EXCEPTION E'Test failed: all three matching usernames should be returned.\nReturned: %', _search_result;
  END IF;

  IF _search_result[1] <> 'concert' THEN
    RAISE EXCEPTION E'Test failed: exact username match should rank first.\nReturned: %', _search_result;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT account_search_order;

SAVEPOINT account_search_anonymous;
DO $$
BEGIN
  PERFORM vibetype_test.invoker_set_anonymous();

  BEGIN
    PERFORM vibetype.account_search('a');
    RAISE EXCEPTION 'Test failed (account_search_anonymous): anonymous invoker was able to search accounts.';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT account_search_anonymous;

SAVEPOINT account_search_block;
DO $$
DECLARE
  _account_a UUID;
  _account_b UUID;
  _search_result TEXT[];
BEGIN
  _account_a := vibetype_test.account_registration_verified('blockfinda', 'blockfinda@example.com');
  _account_b := vibetype_test.account_registration_verified('blockfindb', 'blockfindb@example.com');

  PERFORM vibetype_test.account_block_create(_account_a, _account_b);

  -- The blocker must not find the blocked account.
  PERFORM vibetype_test.invoker_set(_account_a);
  _search_result := ARRAY(SELECT username FROM vibetype.account_search('blockfind') ORDER BY username);
  IF _search_result <> ARRAY['blockfinda'] THEN
    RAISE EXCEPTION E'Test failed (account_search_block): blocker sees blocked account.\nReturned: %', _search_result;
  END IF;

  -- The blocked account must not find the blocker.
  PERFORM vibetype_test.invoker_set(_account_b);
  _search_result := ARRAY(SELECT username FROM vibetype.account_search('blockfind') ORDER BY username);
  IF _search_result <> ARRAY['blockfindb'] THEN
    RAISE EXCEPTION E'Test failed (account_search_block): blocked account sees blocker.\nReturned: %', _search_result;
  END IF;

  -- The definer function itself must not hand out hidden ids either.
  IF EXISTS (SELECT 1 FROM vibetype.account_search_match('blockfind') WHERE account_id = _account_a) THEN
    RAISE EXCEPTION 'Test failed (account_search_block): account_search_match returned the blocker to the blocked account.';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT account_search_block;

SAVEPOINT account_search_match_anonymous;
DO $$
BEGIN
  PERFORM vibetype_test.invoker_set_anonymous();

  BEGIN
    PERFORM vibetype.account_search_match('a');
    RAISE EXCEPTION 'Test failed (account_search_match_anonymous): anonymous invoker was able to execute account_search_match.';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT account_search_match_anonymous;

ROLLBACK;
