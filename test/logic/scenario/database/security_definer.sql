\echo test_security_definer...

-- Every SECURITY DEFINER function must pin its search path with `pg_temp` last.
DO $$
DECLARE
  _functions TEXT;
BEGIN
  SELECT string_agg(p.oid::regprocedure::TEXT, ', ' ORDER BY p.oid::regprocedure::TEXT) INTO _functions
  FROM pg_catalog.pg_proc p
  JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
  WHERE n.nspname IN ('vibetype', 'vibetype_private')
    AND p.prosecdef
    AND NOT EXISTS (
      SELECT 1
      FROM unnest(p.proconfig) AS setting
      WHERE setting ~ '^search_path=.*pg_temp$'
    );

  IF _functions IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: security definer functions without a pinned search path: %. Add `SET search_path = pg_catalog, public, pg_temp`.', _functions;
  END IF;
END $$;
