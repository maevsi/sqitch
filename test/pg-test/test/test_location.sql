\echo test_location...

BEGIN;

DO $$
DECLARE
  _account_id UUID;
  _event_id UUID;
  _coordinates DOUBLE PRECISION[];
  _id UUID;
BEGIN
  -- Register account
  _account_id := vibetype_test.account_registration_verified ('username', 'email@example.com');

  -- Set account-specific context
  SET LOCAL role = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';

  -- Create event
  INSERT INTO vibetype.event(created_by, name, slug, start, visibility)
  VALUES (_account_id, 'event', 'event', CURRENT_TIMESTAMP, 'public'::vibetype.event_visibility)
  RETURNING id INTO _event_id;

  -- Update and validate account location
  PERFORM vibetype_test.account_location_update(_account_id, 51.304, 9.476); -- Somewhere in Kassel
  _coordinates := vibetype_test.account_location_coordinates(_account_id);

  IF NOT (round(_coordinates[1]::numeric, 3) = 51.304 AND round(_coordinates[2]::numeric, 3) = 9.476) THEN
    RAISE EXCEPTION 'Wrong account coordinates';
  END IF;

  -- Update and validate event location
  PERFORM vibetype_test.event_location_update(_event_id, 50.113, 8.650); -- Somewhere in Frankfurt
  _coordinates := vibetype_test.event_location_coordinates(_event_id);

  IF NOT (round(_coordinates[1]::numeric, 3) = 50.113 AND round(_coordinates[2]::numeric, 3) = 8.650) THEN
    RAISE EXCEPTION 'Wrong event coordinates';
  END IF;

  -- Test event filtering by radius from account
  SELECT event_id INTO _id
  FROM vibetype_test.event_filter_radius_account(_account_id, 100);

  IF _id IS NOT NULL THEN
    RAISE EXCEPTION 'Function `event_filter_radius_account` with radius 100 km should have returned an empty result';
  END IF;

  SELECT event_id INTO _id
  FROM vibetype_test.event_filter_radius_account(_account_id, 250);

  IF _id != _event_id THEN
    RAISE EXCEPTION 'Function `event_filter_radius_account` with radius 250 km should have returned `_event_id`';
  END IF;

  -- Test account filtering by radius from event
  SELECT account_id INTO _id
  FROM vibetype_test.account_filter_radius_event(_event_id, 100);

  IF _id IS NOT NULL THEN
    RAISE EXCEPTION 'Function `account_filter_radius_event` with radius 100 km should have returned an empty result';
  END IF;

  SELECT account_id INTO _id
  FROM vibetype_test.account_filter_radius_event(_event_id, 250);

  IF _id != _account_id THEN
    RAISE EXCEPTION 'Function `account_filter_radius_event` with radius 250 km should have returned `_account_id`';
  END IF;
END;
$$ LANGUAGE plpgsql;

ROLLBACK;
