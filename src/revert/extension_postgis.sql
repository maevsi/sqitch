BEGIN;

REVOKE EXECUTE ON FUNCTION
  st_srid(geography),
  st_geomfromgeojson(text),
  st_coorddim(geometry),
  st_asgeojson(geography, integer, integer),
  postgis_type_name(character varying, integer, boolean),
  geometrytype(geography),
  geometry(text),
  geography(geometry)
FROM vibetype_anonymous, vibetype_account;

DROP EXTENSION postgis;

COMMIT;
