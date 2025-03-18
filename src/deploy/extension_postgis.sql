BEGIN;

CREATE EXTENSION postgis;

COMMENT ON EXTENSION postgis IS 'Functions to work with geospatial data.';

GRANT EXECUTE ON FUNCTION
  geography(geometry),
  geometry(text),
  geometrytype(geography),
  postgis_type_name(character varying, integer, boolean),
  st_asgeojson(geography, integer, integer),
  st_coorddim(geometry),
  st_geomfromgeojson(text),
  st_srid(geography)
TO vibetype_anonymous, vibetype_account;

COMMIT;
