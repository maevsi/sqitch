BEGIN;

CREATE EXTENSION postgis WITH SCHEMA maevsi;

COMMENT ON EXTENSION postgis IS 'Functions to work with geospatial data.';

COMMIT;
