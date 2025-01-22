BEGIN;

REVOKE EXECUTE ON FUNCTION
  public.text(public.geometry),
  public.st_srid(public.geometry),
  public.st_geomfromgeojson(text),
  public.st_coorddim(public.geometry),
  public.st_asgeojson(public.geometry, integer, integer),
  public.postgis_type_name(character varying, integer, boolean),
  public.geometrytype(public.geometry),
  public.geometry(text),
  public.geometry(public.geometry, integer, boolean)
FROM maevsi_anonymous, maevsi_account;

DROP EXTENSION postgis;

COMMIT;
