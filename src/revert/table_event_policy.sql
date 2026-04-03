BEGIN;

DROP POLICY event_select ON vibetype.event;
DROP FUNCTION vibetype_private.events_with_claimed_attendance();
DROP POLICY event_all ON vibetype.event;

COMMIT;
