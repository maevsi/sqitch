BEGIN;

DROP TRIGGER vibetype_trigger_attendance_guard ON vibetype.attendance;
DROP FUNCTION vibetype.attendance_guard();

DROP TRIGGER vibetype_trigger_attendance_metadata_update ON vibetype.attendance;

DROP INDEX vibetype.idx_attendance_updated_by;
DROP INDEX vibetype.idx_attendance_contact_id;

DROP TABLE vibetype.attendance;

COMMIT;
