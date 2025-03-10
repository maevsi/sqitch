BEGIN;

CREATE FUNCTION vibetype_test.index_existence(
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

COMMENT ON FUNCTION vibetype_test.index_existence(TEXT[], TEXT) IS 'Checks whether the given indexes exist in the specified schema. Returns 1 if all exist, fails otherwise.';;

COMMIT;
