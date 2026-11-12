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


CREATE OR REPLACE FUNCTION vibetype_test.index_scan_check(
  query TEXT,
  index TEXT
) RETURNS VOID AS $$
DECLARE
  _plan JSONB;
  _seqscan_previous TEXT := current_setting('enable_seqscan');
BEGIN
  -- Seq scans are the only alternative on the tiny test tables, so they are disabled to make the planner pick the index whenever one can serve the query.
  PERFORM set_config('enable_seqscan', 'off', true);
  EXECUTE 'EXPLAIN (FORMAT JSON) ' || index_scan_check.query INTO _plan;
  PERFORM set_config('enable_seqscan', _seqscan_previous, true);

  IF _plan::TEXT NOT LIKE '%"Index Name": "' || index_scan_check.index || '"%' THEN
    RAISE EXCEPTION E'Query does not use index "%":\n%\n%', index_scan_check.index, index_scan_check.query, jsonb_pretty(_plan);
  END IF;
END;
$$ LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_test.index_scan_check(TEXT, TEXT) IS 'Raises an exception unless the plan of the given query scans the given index.';


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
        AND NOT EXISTS (
          SELECT 1
          FROM pg_index i
          WHERE i.indrelid = t.oid
            AND i.indpred IS NULL
            AND (string_to_array(i.indkey::text, ' ')::smallint[])[1:cardinality(c.conkey)] = c.conkey
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
