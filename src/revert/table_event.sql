BEGIN;

DROP TRIGGER search_vector ON vibetype.event;
DROP FUNCTION vibetype.trigger_event_search_vector();
DROP INDEX vibetype.idx_event_search_vector;
DROP TABLE vibetype.event;

COMMIT;
