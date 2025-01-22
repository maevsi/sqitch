BEGIN;

SELECT 1/count(*) FROM pg_extension WHERE extname = 'postgis';
SELECT has_function_privilege('public.ST_DWithin(public.geometry, public.geometry, double precision)', 'EXECUTE');

SAVEPOINT function_privileges_for_roles;
DO $$
DECLARE
  functions TEXT[] := ARRAY[
    'public.geometry(public.GEOMETRY, INTEGER, BOOLEAN)',
    'public.geometry(TEXT)',
    'public.geometrytype(public.GEOMETRY)',
    'public.postgis_type_name(CHARACTER VARYING, INTEGER, BOOLEAN)',
    'public.st_asgeojson(public.GEOMETRY, INTEGER, INTEGER)',
    'public.st_coorddim(public.GEOMETRY)',
    'public.st_geomfromgeojson(TEXT)',
    'public.st_srid(public.GEOMETRY)',
    'public.text(public.GEOMETRY)'
  ];
  roles TEXT[] := ARRAY['maevsi_account', 'maevsi_anonymous'];
  function TEXT;
  role TEXT;
BEGIN
  FOREACH role IN ARRAY roles LOOP
    FOREACH function IN ARRAY functions LOOP
      IF NOT (SELECT pg_catalog.has_function_privilege(role, function, 'EXECUTE')) THEN
        RAISE EXCEPTION 'Test function_privileges_for_roles failed: % does not have EXECUTE privilege on function %', role, function;
      END IF;
    END LOOP;
  END LOOP;
END $$;
ROLLBACK TO SAVEPOINT function_privileges_for_roles;

ROLLBACK;
