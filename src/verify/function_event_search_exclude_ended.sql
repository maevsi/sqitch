BEGIN;

SELECT 1/COUNT(*)
FROM (SELECT pg_get_functiondef('vibetype.event_search(text)'::regprocedure) AS definition) t
WHERE t.definition LIKE '%effective_end%';

DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.event_search(TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_account does not have EXECUTE privilege';
  END IF;

  IF (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.event_search(TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_anonymous should not have EXECUTE privilege';
  END IF;
END $$;

ROLLBACK;
