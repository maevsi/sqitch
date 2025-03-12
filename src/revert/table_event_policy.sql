BEGIN;

DROP POLICY event_update ON vibetype.event;
DROP POLICY event_insert ON vibetype.event;
DROP POLICY event_select ON vibetype.event;

COMMIT;
