BEGIN;

REVOKE EXECUTE ON FUNCTION
  maevsi.text(maevsi.geometry),
  maevsi.st_srid(maevsi.geometry),
  maevsi.st_coorddim(maevsi.geometry),
  maevsi.st_asgeojson(maevsi.geometry, integer, integer),
  maevsi.postgis_type_name(character varying, integer, boolean),
  maevsi.geometrytype(maevsi.geometry),
  maevsi.geometry(text)
FROM maevsi_anonymous, maevsi_account;

DROP EXTENSION postgis;

COMMIT;
