BEGIN;

DROP INDEX vibetype.idx_event_search_vector;
DROP TABLE vibetype.event_search_vector;

COMMIT;
