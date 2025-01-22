BEGIN;

CREATE EXTENSION postgis WITH SCHEMA public;

COMMENT ON EXTENSION postgis IS 'Functions to work with geospatial data.';

GRANT EXECUTE ON FUNCTION
  public.geometry(public.geometry, integer, boolean),
  public.geometry(text),
  public.geometrytype(public.geometry),
  public.postgis_type_name(character varying, integer, boolean),
  public.st_asgeojson(public.geometry, integer, integer),
  public.st_coorddim(public.geometry),
  public.st_geomfromgeojson(text),
  public.st_srid(public.geometry),
  public.text(public.geometry)
TO maevsi_anonymous, maevsi_account;

COMMIT;
