BEGIN;

SELECT 1 / COUNT(*)
FROM pg_catalog.pg_description
WHERE objoid = 'vibetype.event_search_rank(TEXT)'::regprocedure
  AND description LIKE '@behavior -*%';

ROLLBACK;
