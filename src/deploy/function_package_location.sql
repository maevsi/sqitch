BEGIN;

CREATE FUNCTION maevsi.event_distances (
  _account_id UUID,
  _max_distance DOUBLE PRECISION)
RETURNS TABLE (event_id UUID, distance DOUBLE PRECISION) AS $$
BEGIN
  RETURN QUERY
    WITH a AS (
      SELECT location FROM maevsi_private.account WHERE id = _account_id
    )
    SELECT e.id as event_id, maevsi.ST_Distance(a.location, e.location_geography) distance
    FROM a, maevsi.event e
    WHERE maevsi.ST_DWithin(a.location, e.location_geography, _max_distance * 1000);
END; $$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.event_distances(UUID, DOUBLE PRECISION) IS 'Returns event locations within a given radius around the location of an account.';

GRANT EXECUTE ON FUNCTION maevsi.event_distances(UUID, DOUBLE PRECISION) TO maevsi_account;

-------------------------------------------------

CREATE FUNCTION maevsi.account_distances (
  _event_id UUID,
  _max_distance DOUBLE PRECISION)
RETURNS TABLE (account_id UUID, distance DOUBLE PRECISION) AS $$
BEGIN
  -- return account locations within a given radius around the location of an event
  RETURN QUERY
    WITH e AS (
      SELECT location_geography FROM maevsi.event WHERE id = _event_id
    )
    SELECT a.id as account_id,  maevsi.ST_Distance(e.location_geography, a.location) distance
    FROM e, maevsi_private.account a
    WHERE maevsi.ST_DWithin(e.location_geography, a.location, _max_distance * 1000);
END; $$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.account_distances(UUID, DOUBLE PRECISION) IS 'Returns account locations within a given radius around the location of an event.';

GRANT EXECUTE ON FUNCTION maevsi.account_distances(UUID, DOUBLE PRECISION) TO maevsi_account;

-------------------------------------------------

CREATE FUNCTION maevsi.account_location_update (
  _account_id UUID,
  _latitude DOUBLE PRECISION,
  _longitude DOUBLE PRECISION)
RETURNS VOID AS $$
BEGIN
  -- SRID 4839: "ETRS89 / LCC Germany (N-E)", see https://www.crs-geo.eu/crs-pan-european.htm
  -- SRID 4326: "WGS 84" (default SRID)
  UPDATE maevsi_private.account SET
    location = maevsi.ST_Point(_longitude, _latitude, 4326)
  WHERE id = _account_id;
END; $$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.account_location_update(UUID, DOUBLE PRECISION, DOUBLE PRECISION) IS 'Updates an account''s location based on latitude and longitude (GPS coordinates).';

GRANT EXECUTE ON FUNCTION maevsi.account_location_update(UUID, DOUBLE PRECISION, DOUBLE PRECISION) TO maevsi_account;

-------------------------------------------------

CREATE FUNCTION maevsi.event_location_update (
  _event_id UUID,
  _latitude DOUBLE PRECISION,
  _longitude DOUBLE PRECISION)
RETURNS VOID AS $$
BEGIN
  -- SRID 4839: "ETRS89 / LCC Germany (N-E)", see https://www.crs-geo.eu/crs-pan-european.htm
  -- SRID 4326: "WGS 84" (default SRID)
  UPDATE maevsi.event SET
    location_geography = maevsi.ST_Point(_longitude, _latitude, 4326)
  WHERE id = _event_id;
END; $$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.event_location_update(UUID, DOUBLE PRECISION, DOUBLE PRECISION) IS 'Updates an event''s location based on latitude and longitude (GPS coordinates).';

GRANT EXECUTE ON FUNCTION maevsi.event_location_update(UUID, DOUBLE PRECISION, DOUBLE PRECISION) TO maevsi_account;

-------------------------------------------------

CREATE FUNCTION maevsi.get_account_location_coordinates (
  _account_id UUID)
RETURNS DOUBLE PRECISION[] AS $$
DECLARE
  _latitude DOUBLE PRECISION;
  _longitude DOUBLE PRECISION;
BEGIN
  SELECT maevsi.ST_Y(location::maevsi.geometry), maevsi.ST_X(location::maevsi.geometry)
  INTO _latitude, _longitude
  FROM maevsi_private.account
  WHERE id = _account_id;

  RETURN ARRAY[_latitude, _longitude];
END; $$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.get_account_location_coordinates(UUID) IS 'Returns an array with latitude and longitude of the account''s current location data';

GRANT EXECUTE ON FUNCTION maevsi.get_account_location_coordinates(UUID) TO maevsi_account;

-------------------------------------------------

CREATE FUNCTION maevsi.get_event_location_coordinates (
  _event_id UUID)
RETURNS DOUBLE PRECISION[] AS $$
DECLARE
  _latitude DOUBLE PRECISION;
  _longitude DOUBLE PRECISION;
BEGIN
  SELECT maevsi.ST_Y(location_geography::maevsi.geometry), maevsi.ST_X(location_geography::maevsi.geometry)
  INTO _latitude, _longitude
  FROM maevsi.event
  WHERE id = _event_id;
  RETURN ARRAY[_latitude, _longitude];
END; $$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.get_event_location_coordinates(UUID) IS 'Returns an array with latitude and longitude of the event''s current location data.';

GRANT EXECUTE ON FUNCTION maevsi.get_event_location_coordinates(UUID) TO maevsi_account;

COMMIT;
