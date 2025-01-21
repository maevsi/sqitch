BEGIN;

DROP FUNCTION maevsi.event_distances(UUID, DOUBLE PRECISION);
DROP FUNCTION maevsi.account_distances(UUID, DOUBLE PRECISION);

DROP FUNCTION maevsi.account_location_update(UUID, DOUBLE PRECISION, DOUBLE PRECISION);
DROP FUNCTION maevsi.event_location_update(UUID, DOUBLE PRECISION, DOUBLE PRECISION);

DROP FUNCTION maevsi.get_account_location_coordinates(UUID);
DROP FUNCTION maevsi.get_event_location_coordinates(UUID);

COMMIT;
