BEGIN;

CREATE FUNCTION maevsi.distance(
  lat1 DOUBLE PRECISION,
  lon1 DOUBLE PRECISION,
  lat2 DOUBLE PRECISION,
  lon2 DOUBLE PRECISION
) RETURNS DOUBLE PRECISION AS $$
DECLARE
  earthRadius DOUBLE PRECISION;
  r DOUBLE PRECISION;
  hLat DOUBLE PRECISION;
  hLon DOUBLE PRECISION;
  a DOUBLE PRECISION;
  distance DOUBLE PRECISION;
BEGIN
  earthRadius := 6371;
  r := pi() / 180;
  hLat := sin((lat2-lat1)*r/2.0);
  hLon := sin((lon2-lon1)*r/2.0);
  a := hLat*hLat + hLon*hLon*cos(lat1*r)*cos(lat2*r); -- Haversine
  distance := earthRadius * 2 * atan2(sqrt(a), sqrt(1-a));
  -- If atan2 is not available, use asin(least(1, sqrt(a)) (including protection against rounding errors).
  -- distance := earthRadius * 2 * asin(least(1, sqrt(a)))
  RETURN distance;
END;
$$ LANGUAGE PLPGSQL IMMUTABLE;

COMMENT ON FUNCTION maevsi.distance(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION) IS 'Calculate the distance between to locations given their GPS coordinates.';

GRANT EXECUTE ON FUNCTION maevsi.distance(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION) TO maevsi_account;

COMMIT;
