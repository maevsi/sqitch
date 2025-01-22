BEGIN;

SAVEPOINT privileges;
DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.language_iso_full_text_search(maevsi.language)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: maevsi_account does not have EXECUTE privilege';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.language_iso_full_text_search(maevsi.language)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: maevsi_anonymous does not have EXECUTE privilege';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT privileges;

SAVEPOINT success;
DO $$
DECLARE
  _language maevsi.language;
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

    IF maevsi.language_iso_full_text_search(_language) != _result THEN
      RAISE EXCEPTION 'Test failed for input %: Expected % but got %', _language, _result, maevsi.language_iso_full_text_search(lang_code);
    END IF;
  END LOOP;
END $$;
ROLLBACK TO SAVEPOINT success;

SAVEPOINT strict;
DO $$
BEGIN
  IF maevsi.language_iso_full_text_search(NULL::maevsi.language) IS NULL THEN
    RAISE EXCEPTION 'Test failed for NULL input. Did not expect to get NULL.';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT strict;

SAVEPOINT invalid;
DO $$
BEGIN
  BEGIN
    PERFORM maevsi.language_iso_full_text_search('invalid'::maevsi.language);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN;
  END;

  RAISE EXCEPTION 'Test failed: Invalid language ''invalid'' should have raised an exception but did not.';
END $$;
ROLLBACK TO SAVEPOINT invalid;

ROLLBACK;
