CREATE OR REPLACE FUNCTION vibetype_test.event_create (
  _created_by UUID,
  _name TEXT,
  _slug TEXT,
  _start TEXT,
  _visibility TEXT
) RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  SET LOCAL ROLE = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _created_by || '''';

  INSERT INTO vibetype.event(created_by, name, slug, start, visibility)
  VALUES (_created_by, _name, _slug, _start::TIMESTAMP WITH TIME ZONE, _visibility::vibetype.event_visibility)
  RETURNING id INTO _id;

  SET LOCAL ROLE NONE;

  RETURN _id;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.event_create(UUID, TEXT, TEXT, TEXT, TEXT) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.event_select_address_coordinates(
  _event_id UUID
)
RETURNS DOUBLE PRECISION[] AS $$
DECLARE
  _latitude DOUBLE PRECISION;
  _longitude DOUBLE PRECISION;
BEGIN
  SELECT
    ST_Y(a.location::geometry),
    ST_X(a.location::geometry)
  INTO
    _latitude,
    _longitude
  FROM
    vibetype.event e
  JOIN
    vibetype.address a ON e.address_id = a.id
  WHERE
    e.id = _event_id;

  RETURN ARRAY[_latitude, _longitude];
END;
$$ LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_test.event_select_address_coordinates(UUID) IS 'Returns an array with latitude and longitude of the event''s current location data.';

GRANT EXECUTE ON FUNCTION vibetype_test.event_select_address_coordinates(UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.event_select_by_account_distance(
  _account_id UUID,
  _distance_max DOUBLE PRECISION
)
RETURNS TABLE (
  event_id UUID,
  distance DOUBLE PRECISION
) AS $$
  WITH account AS (
    SELECT location
    FROM vibetype_private.account
    WHERE id = _account_id
  )
  SELECT
    e.id AS event_id,
    ST_Distance(a.location, addr.location) AS distance
  FROM
    account a,
    vibetype.event e
  JOIN
    vibetype.address addr ON e.address_id = addr.id
  WHERE
    ST_DWithin(a.location, addr.location, _distance_max * 1000);
$$ LANGUAGE sql STABLE STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_test.event_select_by_account_distance(UUID, DOUBLE PRECISION) IS  'Returns event locations within a given radius around the location of an account.';

GRANT EXECUTE ON FUNCTION vibetype_test.event_select_by_account_distance(UUID, DOUBLE PRECISION) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.event_test (
  _test_case TEXT,
  _account_id UUID,
  _expected_result UUID[]
) RETURNS VOID AS $$
BEGIN
  IF _account_id IS NULL THEN
    SET LOCAL ROLE = 'vibetype_anonymous';
    SET LOCAL jwt.claims.account_id = '';
  ELSE
    SET LOCAL ROLE = 'vibetype_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';
  END IF;

  IF EXISTS (SELECT id FROM vibetype.event EXCEPT SELECT * FROM unnest(_expected_result)) THEN
    RAISE EXCEPTION '%: some event should not appear in the query result', _test_case;
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_result) EXCEPT SELECT id FROM vibetype.event) THEN
    RAISE EXCEPTION '%: some event is missing in the query result', _test_case;
  END IF;

  SET LOCAL ROLE NONE;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.event_test(TEXT, UUID, UUID[]) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.event_update_address_coordinates(
  _event_id UUID,
  _latitude DOUBLE PRECISION,
  _longitude DOUBLE PRECISION
)
RETURNS VOID AS $$
BEGIN
  WITH event AS (
    SELECT address_id
    FROM vibetype.event
    WHERE id = _event_id
  )
  UPDATE vibetype.address
  SET
    location = ST_Point(_longitude, _latitude, 4326)
  WHERE
    id = (SELECT address_id FROM event);
END;
$$ LANGUAGE plpgsql STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_test.event_update_address_coordinates(UUID, DOUBLE PRECISION, DOUBLE PRECISION) IS 'Updates an event''s location based on latitude and longitude (GPS coordinates).';

GRANT EXECUTE ON FUNCTION vibetype_test.event_update_address_coordinates(UUID, DOUBLE PRECISION, DOUBLE PRECISION) TO vibetype_account;
