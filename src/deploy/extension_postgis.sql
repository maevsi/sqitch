BEGIN;

CREATE EXTENSION postgis WITH SCHEMA maevsi;

COMMENT ON EXTENSION postgis IS 'Functions to work with geospatial data.';

GRANT EXECUTE ON FUNCTION
  maevsi.geometry(text),
  maevsi.geometrytype(maevsi.geometry),
  maevsi.postgis_type_name(character varying, integer, boolean),
  maevsi.st_asgeojson(maevsi.geometry, integer, integer),
  maevsi.st_coorddim(maevsi.geometry),
  maevsi.st_srid(maevsi.geometry),
  maevsi.text(maevsi.geometry)
TO maevsi_anonymous, maevsi_account;

COMMIT;
