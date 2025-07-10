BEGIN;

DROP TRIGGER vibetype_trigger_event_search_vector ON vibetype.event;
DROP FUNCTION vibetype.trigger_event_search_vector();
DROP TABLE vibetype.event;

COMMIT;
