BEGIN;

SELECT 1/count(*) FROM pg_extension WHERE extname = 'pg_trgm';

SELECT 1/COUNT(*)
FROM pg_indexes
WHERE schemaname = 'vibetype' AND indexname = 'idx_account_username_like';

DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.account_search(TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_account does not have EXECUTE privilege';
  END IF;

  IF (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.account_search(TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_anonymous should not have EXECUTE privilege';
  END IF;
END $$;

ROLLBACK;