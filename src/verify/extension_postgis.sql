BEGIN;

SELECT 1/count(*) FROM pg_extension WHERE extname = 'postgis';
SELECT has_function_privilege('ST_DWithin(geometry, geometry, double precision)', 'EXECUTE');

SAVEPOINT function_privileges_for_roles;
DO $$
DECLARE
  functions TEXT[] := ARRAY[
    'geography(geometry)',
    'geometry(TEXT)',
    'geometrytype(GEOGRAPHY)',
    'postgis_type_name(CHARACTER VARYING, INTEGER, BOOLEAN)',
    'st_asgeojson(GEOGRAPHY, INTEGER, INTEGER)',
    'st_coorddim(GEOMETRY)',
    'st_geomfromgeojson(TEXT)',
    'st_srid(GEOGRAPHY)'
  ];
  roles TEXT[] := ARRAY['vibetype_account', 'vibetype_anonymous'];
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
