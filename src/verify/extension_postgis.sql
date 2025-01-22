BEGIN;

SELECT 1/count(*) FROM pg_extension WHERE extname = 'postgis';
SELECT has_function_privilege('maevsi.ST_DWithin(maevsi.geometry, maevsi.geometry, double precision)', 'EXECUTE');

SAVEPOINT function_privileges_for_roles;
DO $$
DECLARE
  functions TEXT[] := ARRAY[
    'maevsi.geometry(maevsi.GEOMETRY, INTEGER, BOOLEAN)',
    'maevsi.geometry(TEXT)',
    'maevsi.geometrytype(maevsi.GEOMETRY)',
    'maevsi.postgis_type_name(CHARACTER VARYING, INTEGER, BOOLEAN)',
    'maevsi.st_asgeojson(maevsi.GEOMETRY, INTEGER, INTEGER)',
    'maevsi.st_coorddim(maevsi.GEOMETRY)',
    'maevsi.st_geomfromgeojson(TEXT)',
    'maevsi.st_srid(maevsi.GEOMETRY)',
    'maevsi.text(maevsi.GEOMETRY)'
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
