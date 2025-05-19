BEGIN;

DROP TRIGGER vibetype_guest_update ON vibetype.guest;

DROP FUNCTION vibetype.trigger_guest_update();

DROP POLICY guest_delete ON vibetype.guest;
DROP POLICY guest_update ON vibetype.guest;
DROP POLICY guest_insert ON vibetype.guest;
DROP POLICY guest_select ON vibetype.guest;

COMMIT;
