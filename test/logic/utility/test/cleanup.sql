\echo drop all test functions...

DO $$
DECLARE
  rec RECORD;
BEGIN
  /*
    * Array types are indicated by preceding underscore in the type name
    * WITH ORDINALITY/ORDER BY ordinality is needed to preserve the order of type in p.proargtypes
  */
  FOR rec IN
    SELECT n.nspname, p.proname,
      CASE p.prokind WHEN 'f' THEN 'FUNCTION' ELSE 'PROCEDURE' END prokind, p.proargtypes,
      array_to_string(ARRAY(
        SELECT tn.nspname || '.' ||CASE WHEN substring(t.typname for 1) = '_' THEN substring(t.typname FROM 2) || '[]' ELSE t.typname END
        FROM UNNEST(p.proargtypes) WITH ORDINALITY
          JOIN pg_type t ON UNNEST = t.oid
          JOIN pg_namespace tn ON t.typnamespace = tn.oid
        ORDER BY ordinality
      ), ',') args
    FROM pg_proc p
      JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'vibetype_test'  AND p.prokind IN ('f', 'p') AND proname = 'event_create'
  LOOP
    EXECUTE format('DROP %s %s.%s(%s)', rec.prokind, rec.nspname, rec.proname, rec.args);
  END LOOP;
END $$;
