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
  IF NOT (round(_coordinates[1]::numeric, 3) = 50.113 AND round(_coordinates[2]::numeric, 3) = 8.650) THEN
    RAISE EXCEPTION 'Wrong event coordinates';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_location;


SAVEPOINT event_location_select;
DO $$
DECLARE
  _account_id UUID;
  _event_id UUID;
  _id UUID;
BEGIN
  -- prepare account
  _account_id := vibetype_test.account_registration_verified ('username', 'email@example.com');
  PERFORM vibetype_test.invoker_set(_account_id);
  PERFORM vibetype_test.account_update_address_coordinates(_account_id, 51.304, 9.476); -- Somewhere in Kassel

  -- prepare event
  INSERT INTO vibetype.event(created_by, name, slug, start, visibility)
    VALUES (_account_id, 'event', 'event', CURRENT_TIMESTAMP, 'public'::vibetype.event_visibility)
    RETURNING id INTO _event_id;
  PERFORM vibetype_test.event_update_address_coordinates(_event_id, 50.113, 8.650); -- Somewhere in Frankfurt

  -- test exclusion
  SELECT event_id INTO _id
    FROM vibetype_test.event_select_by_account_distance(_account_id, 100);
  IF _id IS NOT NULL THEN
    RAISE EXCEPTION 'Function `event_select_by_account_distance` with radius 100 km should have returned an empty result';
  END IF;

  -- test inclusion
  SELECT event_id INTO _id
    FROM vibetype_test.event_select_by_account_distance(_account_id, 250);
  IF _id != _event_id THEN
    RAISE EXCEPTION 'Function `event_select_by_account_distance` with radius 250 km should have returned `_event_id`';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_location_select;

ROLLBACK;
