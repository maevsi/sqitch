\echo test_event/location...

BEGIN;

SAVEPOINT event_location;
DO $$
DECLARE
  _account_id UUID;
  _event_id UUID;
  _coordinates DOUBLE PRECISION[];
BEGIN
  -- prepare account
  _account_id := vibetype_test.account_registration_verified ('username', 'email@example.com');
  PERFORM vibetype_test.invoker_set(_account_id);

  -- prepare event
  INSERT INTO vibetype.event(created_by, name, slug, start, visibility)
    VALUES (_account_id, 'event', 'event', CURRENT_TIMESTAMP, 'public'::vibetype.event_visibility)
    RETURNING id INTO _event_id;
  PERFORM vibetype_test.event_update_address_coordinates(_event_id, 50.113, 8.650); -- Somewhere in Frankfurt

  -- test coordinates
  _coordinates := vibetype_test.event_select_address_coordinates(_event_id);
  IF NOT COALESCE(round(_coordinates[1]::numeric, 3) = 50.113 AND round(_coordinates[2]::numeric, 3) = 8.650, FALSE) THEN
    RAISE EXCEPTION 'Wrong event coordinates: %', _coordinates;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_location;


SAVEPOINT event_location_preference_coordinates;
DO $$
DECLARE
  _account_id UUID;
  _latitude DOUBLE PRECISION;
  _longitude DOUBLE PRECISION;
BEGIN
  _account_id := vibetype_test.account_registration_verified ('username', 'email@example.com');
  PERFORM vibetype_test.invoker_set(_account_id);

  INSERT INTO vibetype.preference_event_location (created_by, location, radius)
    VALUES (_account_id, ST_Point(9.476, 51.304, 4326), 100000); -- Somewhere in Kassel

  SELECT ST_Y(location::geometry), ST_X(location::geometry)
    INTO _latitude, _longitude
    FROM vibetype.preference_event_location;

  IF NOT COALESCE(round(_latitude::numeric, 3) = 51.304 AND round(_longitude::numeric, 3) = 9.476, FALSE) THEN
    RAISE EXCEPTION 'Wrong preference event location coordinates: latitude %, longitude %', _latitude, _longitude;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_location_preference_coordinates;


SAVEPOINT event_location_preference_radius;
DO $$
DECLARE
  _account_id UUID;
  _distance DOUBLE PRECISION;
  _event_id UUID;
  _id UUID;
BEGIN
  -- prepare account
  _account_id := vibetype_test.account_registration_verified ('username', 'email@example.com');
  PERFORM vibetype_test.invoker_set(_account_id);

  -- prepare event
  INSERT INTO vibetype.event(created_by, name, slug, start, visibility)
    VALUES (_account_id, 'event', 'event', CURRENT_TIMESTAMP, 'public'::vibetype.event_visibility)
    RETURNING id INTO _event_id;
  PERFORM vibetype_test.event_update_address_coordinates(_event_id, 50.113, 8.650); -- Somewhere in Frankfurt

  -- test exclusion: Kassel and Frankfurt are about 145 km apart
  INSERT INTO vibetype.preference_event_location (created_by, location, radius)
    VALUES (_account_id, ST_Point(9.476, 51.304, 4326), 100000); -- Somewhere in Kassel

  SELECT event_id INTO _id
    FROM vibetype_test.event_select_by_preference_event_location(_account_id);
  IF _id IS NOT NULL THEN
    RAISE EXCEPTION 'Function `event_select_by_preference_event_location` with radius 100 km should have returned an empty result';
  END IF;

  -- test inclusion (accounts may not update preferences, so replace the row)
  DELETE FROM vibetype.preference_event_location;
  INSERT INTO vibetype.preference_event_location (created_by, location, radius)
    VALUES (_account_id, ST_Point(9.476, 51.304, 4326), 250000);

  SELECT event_id, distance INTO _id, _distance
    FROM vibetype_test.event_select_by_preference_event_location(_account_id);
  IF _id IS DISTINCT FROM _event_id THEN
    RAISE EXCEPTION 'Function `event_select_by_preference_event_location` with radius 250 km should have returned `_event_id`';
  END IF;

  -- test that the distance is in meters on the spheroid, not in degrees
  IF NOT COALESCE(_distance BETWEEN 140000 AND 150000, FALSE) THEN
    RAISE EXCEPTION 'Distance between Kassel and Frankfurt should be about 145 km, got % m', _distance;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_location_preference_radius;

ROLLBACK;
