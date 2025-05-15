\echo test_account...

BEGIN;

SAVEPOINT account_location;
DO $$
DECLARE
  _account_id UUID;
  _coordinates DOUBLE PRECISION[];
BEGIN
  -- prepare account
  _account_id := vibetype_test.account_registration_verified ('username', 'email@example.com');
  PERFORM vibetype_test.invoker_set(_account_id);
  PERFORM vibetype_test.account_update_address_coordinates(_account_id, 51.304, 9.476); -- Somewhere in Kassel

  -- test coordinates
  _coordinates := vibetype_test.account_select_address_coordinates(_account_id);
  IF NOT (round(_coordinates[1]::numeric, 3) = 51.304 AND round(_coordinates[2]::numeric, 3) = 9.476) THEN
    RAISE EXCEPTION 'Wrong account coordinates';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT account_location;


SAVEPOINT account_location_select;
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
  SELECT account_id INTO _id
    FROM vibetype_test.account_select_by_event_distance(_event_id, 100);
  IF _id IS NOT NULL THEN
    RAISE EXCEPTION 'Function `account_select_by_event_distance` with radius 100 km should have returned an empty result';
  END IF;

  -- test inclusion
  SELECT account_id INTO _id
    FROM vibetype_test.account_select_by_event_distance(_event_id, 250);
  IF _id != _account_id THEN
    RAISE EXCEPTION 'Function `account_select_by_event_distance` with radius 250 km should have returned `_account_id`';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT account_location_select;

ROLLBACK;
