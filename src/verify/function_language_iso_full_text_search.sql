BEGIN;

SAVEPOINT privileges;
DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.language_iso_full_text_search(vibetype.language)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_account does not have EXECUTE privilege';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.language_iso_full_text_search(vibetype.language)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_anonymous does not have EXECUTE privilege';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT privileges;

SAVEPOINT success;
DO $$
DECLARE
  _language vibetype.language;
  _result regconfig;
BEGIN
  FOREACH _language IN ARRAY
    ARRAY['de', 'en', NULL]
  LOOP
    CASE _language
      WHEN 'de' THEN _result := 'pg_catalog.german';
      WHEN 'en' THEN _result := 'pg_catalog.english';
      ELSE _result := 'pg_catalog.simple';
    END CASE;

    IF vibetype.language_iso_full_text_search(_language) != _result THEN
      RAISE EXCEPTION 'Test failed for input %: Expected % but got %', _language, _result, vibetype.language_iso_full_text_search(lang_code);
    END IF;
  END LOOP;
END $$;
ROLLBACK TO SAVEPOINT success;

SAVEPOINT strict;
DO $$
BEGIN
  IF vibetype.language_iso_full_text_search(NULL::vibetype.language) IS NULL THEN
    RAISE EXCEPTION 'Test failed for NULL input. Did not expect to get NULL.';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT strict;

SAVEPOINT invalid;
DO $$
BEGIN
  BEGIN
    PERFORM vibetype.language_iso_full_text_search('invalid'::vibetype.language);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN;
  END;

  RAISE EXCEPTION 'Test failed: Invalid language ''invalid'' should have raised an exception but did not.';
END $$;
ROLLBACK TO SAVEPOINT invalid;

ROLLBACK;
