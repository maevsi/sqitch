BEGIN;

DROP TRIGGER maevsi_trigger_event_search_vector ON maevsi.event;
DROP FUNCTION maevsi.trigger_event_search_vector();
DROP TABLE maevsi.event;

COMMIT;
