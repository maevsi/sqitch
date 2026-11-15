BEGIN;

-- The `CREATE` privilege on schema `public` stays revoked, as its previous state is unknown.
DO $$
DECLARE
  _function regprocedure;
BEGIN
  FOR _function IN
    SELECT p.oid::regprocedure
    FROM pg_catalog.pg_proc p
    JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname IN ('vibetype', 'vibetype_private')
      AND p.prosecdef
  LOOP
    EXECUTE format('ALTER FUNCTION %s RESET search_path', _function);
  END LOOP;
END $$;

COMMIT;
