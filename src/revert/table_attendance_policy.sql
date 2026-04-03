BEGIN;

DROP POLICY attendance_update ON vibetype.attendance;
DROP POLICY attendance_insert ON vibetype.attendance;
DROP POLICY attendance_select ON vibetype.attendance;
DROP FUNCTION vibetype_private.attendance_via_own_events();
DROP FUNCTION vibetype_private.attendance_via_own_contact();
DROP FUNCTION vibetype_private.attendance_row_visible(UUID);

REVOKE ALL PRIVILEGES ON TABLE vibetype.attendance FROM vibetype_anonymous;
REVOKE ALL PRIVILEGES ON TABLE vibetype.attendance FROM vibetype_account;

COMMIT;
