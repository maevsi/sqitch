BEGIN;

SELECT 1/COUNT(*)
FROM (SELECT pg_get_functiondef('vibetype.event_search(text, vibetype.language)'::regprocedure) AS definition) t
WHERE t.definition LIKE '%effective_end%';

SAVEPOINT privileges;
DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.event_search(TEXT, vibetype.language)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_account does not have EXECUTE privilege';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.event_search(TEXT, vibetype.language)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_anonymous does not have EXECUTE privilege';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT privileges;

ROLLBACK;
