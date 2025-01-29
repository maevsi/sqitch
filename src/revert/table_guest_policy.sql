BEGIN;

DROP TRIGGER maevsi_guest_update ON maevsi.guest;

DROP FUNCTION maevsi.trigger_guest_update;

DROP POLICY guest_select ON maevsi.guest;
DROP POLICY guest_insert ON maevsi.guest;
DROP POLICY guest_update ON maevsi.guest;
DROP POLICY guest_delete ON maevsi.guest;

COMMIT;
