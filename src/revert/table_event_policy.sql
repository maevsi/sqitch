BEGIN;

DROP POLICY event_all ON vibetype.event;
DROP POLICY event_select ON vibetype.event;

COMMIT;
