BEGIN;

CREATE TABLE maevsi.location (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  location_type CHAR(1) NOT NULL,
  latitude      DOUBLE PRECISION NOT NULL,
  longitude     DOUBLE PRECISION NOT NULL,

  -- -- possible future extension using PostGIS
  -- geom          GEOMETRY

  CHECK (location_type IN ('A', 'E'))
);

COMMENT ON TABLE maevsi.location IS 'Location data based on GPS coordnates.';
COMMENT ON COLUMN maevsi.location.id IS E'@omit create,update\nThe locations''s internal id.';
COMMENT ON COLUMN maevsi.location.location_type IS 'The type of the location (A = account, E = event)';
COMMENT ON COLUMN maevsi.location.latitude IS 'The coordinate''s latitude.';
COMMENT ON COLUMN maevsi.location.longitude IS 'The coordinate''s longitude.';

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE maevsi.location TO maevsi_account;
GRANT SELECT ON TABLE maevsi.location TO maevsi_anonymous;

/*
-- If PostGIS is used:

-- A spatial index could be used by function ST_DWithin (returning true if distance between
-- two locations location is <= a given distance.
CREATE INDEX maevsi.location_geom_idx ON maevsi.location USING GIST (geom);

CREATE FUNCTION maevsi.location_update_geom() RETURNS TRIGGER AS $$
  BEGIN
    NEW.geom = ST_Point(NEW.longitude, NEW.latitude, 4326);
    RETURN NEW;
  END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.location_update_geom() IS 'Sets column geom to a value based on longitude and latitude, using spatial reference id 4326.';

GRANT EXECUTE ON FUNCTION maevsi.location_update_geom() TO maevsi_account;

CREATE TRIGGER maevsi_location_update_geom
  BEFORE
       INSERT
    OR UPDATE OF latitude, longitude
  ON maevsi.location
  FOR EACH ROW
    EXECUTE PROCEDURE maevsi.location_update_geom();
*/

COMMIT;
