BEGIN;

CREATE EXTENSION postgis WITH SCHEMA public;

COMMENT ON EXTENSION postgis IS 'Functions to work with geospatial data.';

GRANT EXECUTE ON FUNCTION
  public.geography(public.geometry),
  public.geometry(text),
  public.geometrytype(public.geography),
  public.postgis_type_name(character varying, integer, boolean),
  public.st_asgeojson(public.geography, integer, integer),
  public.st_coorddim(public.geometry),
  public.st_geomfromgeojson(text),
  public.st_srid(public.geography)
TO maevsi_anonymous, maevsi_account;

COMMIT;
