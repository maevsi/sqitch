\echo drop all test functions...

DO $$
DECLARE
  rec RECORD;
BEGIN

  FOR rec IN
    SELECT n.nspname, p.proname,
      CASE p.prokind WHEN 'f' THEN 'FUNCTION' ELSE 'PROCEDURE' END prokind,
      array_to_string(ARRAY(
        SELECT CASE WHEN substring(t.typname for 1) = '_' THEN substring(t.typname FROM 2) || '[]' ELSE t.typname END
        FROM UNNEST(p.proargtypes) WITH ORDINALITY JOIN pg_type t ON UNNEST = t.oid
        ORDER BY ordinality
      ), ',') args
    FROM pg_proc p
      JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname = 'vibetype_test'  AND p.prokind IN ('f', 'p')
  LOOP

--  RAISE NOTICE 'DROP % %.%(%)', rec.prokind, rec.nspname, rec.proname, rec.args;
    EXECUTE format('DROP %s %s.%s(%s)', rec.prokind, rec.nspname, rec.proname, rec.args);
  END LOOP;

END $$;

/*
Comments:
  * Array types are indicated by preceding underscore in the type name
  * WITH ORDINALITY/ORDER BY ordinality is needed to preserve the order of type in p.proargtypes
*/