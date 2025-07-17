BEGIN;

DO $$
DECLARE
  _account_id UUID;
  usernames TEXT[];
  _username TEXT;
  search_strings TEXT[];
  search_string TEXT;
  expected_result TEXT[];
  search_result TEXT[];
BEGIN

  usernames := ARRAY['abc', 'cdef', 'BcblfGa', 'ffg56H'];

  FOREACH _username IN ARRAY usernames
  LOOP
    IF _username = 'abc' THEN
       _account_id := vibetype_test.account_registration_verified(_username, lower(_username) ||'@example.com');
    ELSE
       PERFORM vibetype_test.account_registration_verified(_username, lower(_username) ||'@example.com');
    END IF;
  END LOOP;

  -- switch to user 'abc' who should not appear in the search result
  SET LOCAL ROLE = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';

  search_strings := ARRAY['A', 'a', 'c', 'f' , 'fg', 'fh'];

  FOREACH search_string IN ARRAY search_strings
  LOOP

    search_result := ARRAY(SELECT username FROM vibetype.account_search(search_string));

    expected_result :=
    CASE search_string
      WHEN 'A' THEN ARRAY['abc', 'BcblfGa']
      WHEN 'a' THEN ARRAY['abc', 'BcblfGa']
      WHEN 'c' THEN ARRAY['abc', 'BcblfGa', 'cdef']
      WHEN 'f' THEN ARRAY['BcblfGa', 'cdef', 'ffg56H']
      WHEN 'fg' THEN ARRAY['BcblfGa', 'ffg56H']
      WHEN 'fh' THEN ARRAY[]::text[]
    END;

    -- RAISE NOTICE 'search_string: % => search_result: %, expected_result: %', search_string, search_result, expected_result;

    IF search_result <> expected_result THEN
      RAISE EXCEPTION 'search for % does not return the expected result', search_string;
    END IF;

  END LOOP;

END $$;

ROLLBACK;
