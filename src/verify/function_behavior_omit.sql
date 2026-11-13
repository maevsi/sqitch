BEGIN;

SELECT 1 / (COUNT(*) = 2)::INTEGER
FROM pg_catalog.pg_description
WHERE objoid IN ('vibetype.account_search_match(TEXT)'::regprocedure, 'vibetype.event_search_rank(TEXT)'::regprocedure)
  AND description LIKE '@behavior -*%';

ROLLBACK;
