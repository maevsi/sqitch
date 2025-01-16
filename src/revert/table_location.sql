BEGIN;

--DROP TRIGGER maevsi_location_update_geom ON maevsi.location;
--DROP FUNCTION maevsi.location_update_geom();
DROP TABLE maevsi.location;

COMMIT;
