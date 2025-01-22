BEGIN;

REVOKE EXECUTE ON FUNCTION
  public.st_srid(public.geography),
  public.st_geomfromgeojson(text),
  public.st_coorddim(public.geometry),
  public.st_asgeojson(public.geography, integer, integer),
  public.postgis_type_name(character varying, integer, boolean),
  public.geometrytype(public.geography),
  public.geometry(text),
  public.geography(public.geometry)
FROM maevsi_anonymous, maevsi_account;

DROP EXTENSION postgis;

COMMIT;
