BEGIN;

DROP FUNCTION vibetype_test.account_filter_radius_event(UUID, DOUBLE PRECISION);
DROP FUNCTION vibetype_test.event_filter_radius_account(UUID, DOUBLE PRECISION);

DROP FUNCTION vibetype_test.account_location_update(UUID, DOUBLE PRECISION, DOUBLE PRECISION);
DROP FUNCTION vibetype_test.event_location_update(UUID, DOUBLE PRECISION, DOUBLE PRECISION);

DROP FUNCTION vibetype_test.account_location_coordinates(UUID);
DROP FUNCTION vibetype_test.event_location_coordinates(UUID);

COMMIT;
