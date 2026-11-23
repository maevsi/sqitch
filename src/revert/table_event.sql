BEGIN;

DROP TRIGGER published_at ON vibetype.event;
DROP FUNCTION vibetype.trigger_event_published_at();
DROP TRIGGER search_vector ON vibetype.event;
DROP FUNCTION vibetype.trigger_event_search_vector();
DROP INDEX vibetype.idx_event_name_trgm;
DROP TABLE vibetype.event;

COMMIT;
