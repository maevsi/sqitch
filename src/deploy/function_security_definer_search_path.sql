BEGIN;

-- A SECURITY DEFINER function resolves unqualified names through the caller's
-- search path, in which the caller's temporary schema comes first for types
-- and tables. Pinning the path, with `pg_temp` last, keeps a caller from
-- substituting objects that would then run with the owner's privileges.
-- `public` holds the extensions and must not be writable for that to hold.
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

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
    EXECUTE format('ALTER FUNCTION %s SET search_path = pg_catalog, public, pg_temp', _function);
  END LOOP;
END $$;

COMMIT;
