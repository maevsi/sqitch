BEGIN;

DO $$
DECLARE
  _account_id UUID;
  _event_id UUID;
  _coordinates DOUBLE PRECISION[];
  _id UUID;
BEGIN

  _account_id := maevsi.account_registration('username', 'email@example.com', 'password', 'en');
  PERFORM maevsi.account_email_address_verification(
    (SELECT email_address_verification FROM maevsi_private.account WHERE id = _account_id)
  );

  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';

  INSERT INTO maevsi.event(author_account_id, name, slug, start, visibility)
  VALUES (_account_id, 'event', 'event', CURRENT_TIMESTAMP, 'public'::maevsi.event_visibility)
  RETURNING id INTO _event_id;

  -------------------------------------

  PERFORM maevsi.account_location_update(_account_id, 51.304, 9.476); -- somewhere in Kassel

  _coordinates := maevsi.get_account_location_coordinates(_account_id);

  IF NOT (round(_coordinates[1]::numeric, 3) = 51.304 AND round(_coordinates[2]::numeric, 3) = 9.476) THEN
    RAISE EXCEPTION 'wrong account coordinates.';
  END IF;

  -------------------------------------

  PERFORM maevsi.event_location_update(_event_id, 50.113,	8.650); -- somewhere in Frankfurt

  _coordinates := maevsi.get_event_location_coordinates(_event_id);

  IF NOT (round(_coordinates[1]::numeric, 3) = 50.113 AND round(_coordinates[2]::numeric, 3) = 8.650) THEN
    RAISE EXCEPTION 'wrong event coordinates.';
  END IF;

  -------------------------------------

  SELECT event_id INTO _id
  FROM maevsi.maevsi.event_distances(_account_id, 100);

  IF _id IS NOT NULL THEN
    RAISE EXCEPTION 'function event_distances with radius 100 km should have returned an empty result.';
  END IF;

  SELECT event_id INTO _id
  FROM maevsi.maevsi.event_distances(_account_id, 250);

  IF _id != _event_id THEN
    RAISE EXCEPTION 'function event_distances with radius 250 km should have returned _event_id.';
  END IF;

  -------------------------------------

  SELECT account_id INTO _id
  FROM maevsi.maevsi.account_distances(_event_id, 100);

  IF _id IS NOT NULL THEN
    RAISE EXCEPTION 'function account_distances with radius 100 km should have returned an empty result.';
  END IF;

  SELECT account_id INTO _id
  FROM maevsi.maevsi.account_distances(_event_id, 250);

  IF _id != _account_id THEN
    RAISE EXCEPTION 'function account_distances with radius 250 km should have returned _account_id.';
  END IF;

  -------------------------------------

  RAISE NOTICE 'tests ok';

END; $$ LANGUAGE plpgsql;

ROLLBACK;
