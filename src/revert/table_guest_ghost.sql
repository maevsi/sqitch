BEGIN;

DROP TRIGGER is_ghost ON vibetype.guest;
DROP FUNCTION vibetype.trigger_guest_is_ghost();

ALTER TABLE vibetype.guest DROP COLUMN is_ghost;

COMMIT;
