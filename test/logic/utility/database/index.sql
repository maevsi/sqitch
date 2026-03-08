CREATE OR REPLACE FUNCTION vibetype_test.index_existence(
  indexes TEXT[],
  schema TEXT DEFAULT 'vibetype'
) RETURNS VOID AS $$
DECLARE
  _existing_count INTEGER;
  _expected_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO _existing_count
  FROM pg_indexes
  WHERE schemaname = index_existence.schema
    AND indexname = ANY(index_existence.indexes);

  _expected_count := array_length(index_existence.indexes, 1);

  IF _existing_count <> _expected_count THEN
    RAISE EXCEPTION 'Index mismatch in schema "%". Expected: %, Found: %', schema, _expected_count, _existing_count;
  END IF;
END;
$$ LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_test.index_existence(TEXT[], TEXT) IS 'Checks whether the given indexes exist in the specified schema. Raises an exception if any are missing.';


CREATE OR REPLACE FUNCTION vibetype_test.index_on_foreign_key_check()
RETURNS VOID AS $$
DECLARE
  rec RECORD;
  violation_details TEXT := '';
BEGIN
  FOR rec IN
    WITH index_not_found AS (
      SELECT n.nspname, t.relname, c.conname, c.conkey
      FROM pg_constraint c
         JOIN pg_class t ON (c.conrelid = t.oid)
         JOIN pg_namespace n ON (t.relnamespace = n.oid)
      WHERE c.contype = 'f' AND t.relkind = 'r'
        AND n.nspname IN ('vibetype', 'vibetype_private')
        AND (n.nspname, t.relname, c.conkey) NOT IN (
          SELECT n.nspname, t.relname, string_to_array(i.indkey::text, ' ')::smallint[] AS indkey
          FROM pg_index i
            JOIN pg_class t ON (i.indrelid = t.oid)
            JOIN pg_namespace n ON (t.relnamespace = n.oid)
          WHERE t.relkind = 'r'
            AND n.nspname IN ('vibetype', 'vibetype_private')
        )
    )
    SELECT nspname || '.' || relname || ':' || conname || ',' || conkey::TEXT AS violation_details
    FROM index_not_found
    ORDER BY nspname, relname, conname
  LOOP
    violation_details := violation_details || E'\n' || rec.violation_details;
  END LOOP;

  -- If missing indexes exist, raise an exception
  IF LENGTH(violation_details) > 0 THEN
    RAISE EXCEPTION E'Foreign key constraints without indexes:\n%', violation_details;
  END IF;
END;
$$ LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER;
