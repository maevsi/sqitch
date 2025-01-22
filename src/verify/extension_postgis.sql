BEGIN;

SELECT 1/count(*) FROM pg_extension WHERE extname = 'postgis';
SELECT has_function_privilege('public.ST_DWithin(public.geometry, public.geometry, double precision)', 'EXECUTE');

ROLLBACK;
