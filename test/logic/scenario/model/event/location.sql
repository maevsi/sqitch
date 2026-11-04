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

ROLLBACK;
