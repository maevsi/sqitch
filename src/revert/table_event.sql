BEGIN;

DROP TRIGGER maevsi_trigger_event_search_vector ON maevsi.event;
DROP FUNCTION maevsi.trigger_event_search_vector();
DROP INDEX maevsi.idx_event_created_by;
DROP INDEX maevsi.idx_event_search_vector;
DROP INDEX maevsi.idx_event_location;
DROP TABLE maevsi.event;

COMMIT;
