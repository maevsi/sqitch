BEGIN;

DROP POLICY event_update ON maevsi.event;
DROP POLICY event_insert ON maevsi.event;
DROP POLICY event_select ON maevsi.event;

COMMIT;
