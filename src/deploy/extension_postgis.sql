BEGIN;

CREATE EXTENSION postgis WITH SCHEMA public;

COMMENT ON EXTENSION postgis IS 'Functions to work with geospatial data.';

COMMIT;
