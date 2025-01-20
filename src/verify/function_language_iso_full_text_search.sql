BEGIN;

SAVEPOINT privileges;
DO $$
BEGIN
  IF (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi_private.language_iso_full_text_search(maevsi.language)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: maevsi_account does not have EXECUTE privilege';
  END IF;

  IF (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi_private.language_iso_full_text_search(maevsi.language)', 'EXECUTE')) THEN
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
    ARRAY['de', 'en']
  LOOP
    CASE _language
      WHEN 'de' THEN _result := 'pg_catalog.german';
      WHEN 'en' THEN _result := 'pg_catalog.english';
    END CASE;

    IF maevsi_private.language_iso_full_text_search(_language) != _result THEN
      RAISE EXCEPTION 'Test failed for input %: Expected % but got %', _language, _result, maevsi_private.language_iso_full_text_search(lang_code);
    END IF;
  END LOOP;
END $$;
ROLLBACK TO SAVEPOINT success;

SAVEPOINT strict;
DO $$
BEGIN
  IF maevsi_private.language_iso_full_text_search(NULL::maevsi.language) IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed for NULL input. Expected NULL but got %', maevsi_private.language_iso_full_text_search(NULL::maevsi.language);
  END IF;
END $$;
ROLLBACK TO SAVEPOINT strict;

SAVEPOINT invalid;
DO $$
BEGIN
  BEGIN
    PERFORM maevsi_private.language_iso_full_text_search('invalid'::maevsi.language);
    RAISE EXCEPTION 'Test failed: Invalid language ''invalid'' should have raised an exception but did not.';
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;
END $$;
ROLLBACK TO SAVEPOINT invalid;

ROLLBACK;
