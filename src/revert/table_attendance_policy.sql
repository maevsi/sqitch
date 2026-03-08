BEGIN;

DROP POLICY attendance_update ON vibetype.attendance;
DROP POLICY attendance_insert ON vibetype.attendance;
DROP POLICY attendance_select ON vibetype.attendance;
DROP FUNCTION vibetype_private.attendance_policy_select(vibetype.attendance);

REVOKE ALL PRIVILEGES ON TABLE vibetype.attendance FROM vibetype_anonymous;
REVOKE ALL PRIVILEGES ON TABLE vibetype.attendance FROM vibetype_account;

COMMIT;
