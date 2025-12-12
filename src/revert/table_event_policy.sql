BEGIN;

DROP POLICY event_select ON vibetype.event;
DROP FUNCTION vibetype_private.event_policy_select(vibetype.event);
DROP POLICY event_all ON vibetype.event;

COMMIT;
