BEGIN;

DROP TRIGGER outbox ON vibetype.event;
DROP FUNCTION vibetype.trigger_event_outbox();
DROP TRIGGER search_vector ON vibetype.event;
DROP FUNCTION vibetype.trigger_event_search_vector();
DROP INDEX vibetype.idx_event_name_trgm;
DROP TABLE vibetype.event;

COMMIT;
