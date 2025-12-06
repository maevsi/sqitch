CREATE OR REPLACE FUNCTION vibetype_test.uuid_array_test (
  _test_case TEXT,
  _array UUID[],
  _expected_array UUID[]
)
RETURNS VOID AS $$
BEGIN
  IF EXISTS (SELECT * FROM unnest(_array) EXCEPT SELECT * FROM unnest(_expected_array)) THEN
    RAISE EXCEPTION '%: some uuid should not appear in the array', _test_case;
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_array) EXCEPT SELECT * FROM unnest(_array)) THEN
    RAISE EXCEPTION '%: some expected uuid is missing in the array', _test_case;
  END IF;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.uuid_array_test(TEXT, UUID[], UUID[]) TO vibetype_account, vibetype_anonymous;
