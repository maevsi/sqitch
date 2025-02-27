BEGIN;


CREATE FUNCTION maevsi_test.account_filter_radius_event(
  _event_id UUID,
  _distance_max DOUBLE PRECISION
)
RETURNS TABLE (
  account_id UUID,
  distance DOUBLE PRECISION
) AS $$
BEGIN
  RETURN QUERY
    WITH event AS (
      SELECT address_id
      FROM maevsi.event
      WHERE id = _event_id
    ),
    event_address AS (
      SELECT location
      FROM maevsi.address
      WHERE id = (SELECT address_id FROM event)
    )
    SELECT
      a.id AS account_id,
      ST_Distance(e.location, a.location) AS distance
    FROM
      event_address e,
      maevsi_private.account a
    WHERE
      ST_DWithin(e.location, a.location, _distance_max * 1000);
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi_test.account_filter_radius_event(UUID, DOUBLE PRECISION) IS 'Returns account locations within a given radius around the location of an event.';

GRANT EXECUTE ON FUNCTION maevsi_test.account_filter_radius_event(UUID, DOUBLE PRECISION) TO maevsi_account;


CREATE FUNCTION maevsi_test.event_filter_radius_account(
  _account_id UUID,
  _distance_max DOUBLE PRECISION
)
RETURNS TABLE (
  event_id UUID,
  distance DOUBLE PRECISION
) AS $$
BEGIN
  RETURN QUERY
    WITH account AS (
      SELECT location
      FROM maevsi_private.account
      WHERE id = _account_id
    )
    SELECT
      e.id AS event_id,
      ST_Distance(a.location, addr.location) AS distance
    FROM
      account a,
      maevsi.event e
    JOIN
      maevsi.address addr ON e.address_id = addr.id
    WHERE
      ST_DWithin(a.location, addr.location, _distance_max * 1000);
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi_test.event_filter_radius_account(UUID, DOUBLE PRECISION) IS  'Returns event locations within a given radius around the location of an account.';

GRANT EXECUTE ON FUNCTION maevsi_test.event_filter_radius_account(UUID, DOUBLE PRECISION) TO maevsi_account;


CREATE FUNCTION maevsi_test.account_location_update(
  _account_id UUID,
  _latitude DOUBLE PRECISION,
  _longitude DOUBLE PRECISION
)
RETURNS VOID AS $$
BEGIN
  UPDATE maevsi_private.account
  SET
    location = ST_Point(_longitude, _latitude, 4326)
  WHERE
    id = _account_id;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi_test.account_location_update(UUID, DOUBLE PRECISION, DOUBLE PRECISION) IS 'Updates an account''s location based on latitude and longitude (GPS coordinates).';

GRANT EXECUTE ON FUNCTION maevsi_test.account_location_update(UUID, DOUBLE PRECISION, DOUBLE PRECISION) TO maevsi_account;


CREATE FUNCTION maevsi_test.event_location_update(
  _event_id UUID,
  _latitude DOUBLE PRECISION,
  _longitude DOUBLE PRECISION
)
RETURNS VOID AS $$
BEGIN
  WITH event AS (
    SELECT address_id
    FROM maevsi.event
    WHERE id = _event_id
  )
  UPDATE maevsi.address
  SET
    location = ST_Point(_longitude, _latitude, 4326)
  WHERE
    id = (SELECT address_id FROM event);
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi_test.event_location_update(UUID, DOUBLE PRECISION, DOUBLE PRECISION) IS 'Updates an event''s location based on latitude and longitude (GPS coordinates).';

GRANT EXECUTE ON FUNCTION maevsi_test.event_location_update(UUID, DOUBLE PRECISION, DOUBLE PRECISION) TO maevsi_account;


CREATE FUNCTION maevsi_test.account_location_coordinates(
  _account_id UUID
)
RETURNS DOUBLE PRECISION[] AS $$
DECLARE
  _latitude DOUBLE PRECISION;
  _longitude DOUBLE PRECISION;
BEGIN
  SELECT
    ST_Y(location::geometry),
    ST_X(location::geometry)
  INTO
    _latitude,
    _longitude
  FROM
    maevsi_private.account
  WHERE
    id = _account_id;

  RETURN ARRAY[_latitude, _longitude];
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi_test.account_location_coordinates(UUID) IS 'Returns an array with latitude and longitude of the account''s current location data';

GRANT EXECUTE ON FUNCTION maevsi_test.account_location_coordinates(UUID) TO maevsi_account;


CREATE FUNCTION maevsi_test.event_location_coordinates(
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
    maevsi.event e
  JOIN
    maevsi.address a ON e.address_id = a.id
  WHERE
    e.id = _event_id;

  RETURN ARRAY[_latitude, _longitude];
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi_test.event_location_coordinates(UUID) IS 'Returns an array with latitude and longitude of the event''s current location data.';

GRANT EXECUTE ON FUNCTION maevsi_test.event_location_coordinates(UUID) TO maevsi_account;


COMMIT;
