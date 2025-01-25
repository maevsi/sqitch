BEGIN;

DROP FUNCTION maevsi.account_filter_radius_event(UUID, DOUBLE PRECISION);
DROP FUNCTION maevsi.event_filter_radius_account(UUID, DOUBLE PRECISION);

DROP FUNCTION maevsi.account_location_update(UUID, DOUBLE PRECISION, DOUBLE PRECISION);
DROP FUNCTION maevsi.event_location_update(UUID, DOUBLE PRECISION, DOUBLE PRECISION);

DROP FUNCTION maevsi.account_location_coordinates(UUID);
DROP FUNCTION maevsi.event_location_coordinates(UUID);

COMMIT;
