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
    _search_result := ARRAY(SELECT username FROM vibetype.account_search(_search_string));

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

ROLLBACK;
