BEGIN;

SELECT 1/count(*) FROM pg_extension WHERE extname = 'postgis';
SELECT has_function_privilege('maevsi.ST_DWithin(maevsi.geometry, maevsi.geometry, double precision)', 'EXECUTE');

ROLLBACK;
