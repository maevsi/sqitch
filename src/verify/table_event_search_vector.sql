BEGIN;

SELECT event_id,
       ts_config,
       search_vector
FROM vibetype_private.event_search_vector WHERE FALSE;

SELECT 1/COUNT(*)
FROM pg_indexes
WHERE schemaname = 'vibetype_private' AND indexname = 'idx_event_search_vector';

SELECT 1/COUNT(*)
FROM pg_indexes
WHERE schemaname = 'vibetype_private' AND indexname = 'idx_event_search_vector_event_id';

ROLLBACK;
