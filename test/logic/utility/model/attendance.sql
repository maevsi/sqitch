CREATE OR REPLACE FUNCTION vibetype_test.attendance_create (
  _created_by UUID,
  _guest_id UUID
) RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  PERFORM vibetype_test.invoker_set(_created_by);

  INSERT INTO vibetype.attendance(guest_id)
  VALUES (_guest_id)
  RETURNING id INTO _id;

  PERFORM vibetype_test.invoker_set_previous();

  RETURN _id;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.attendance_create(UUID, UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.attendance_test (
  _test_case TEXT,
  _account_id UUID,
  _expected_result UUID[]
) RETURNS VOID AS $$
BEGIN
  IF _account_id IS NULL THEN
    PERFORM vibetype_test.invoker_set_anonymous();
  ELSE
    PERFORM vibetype_test.invoker_set(_account_id);
  END IF;

  IF EXISTS (SELECT id FROM vibetype.attendance EXCEPT SELECT * FROM unnest(_expected_result)) THEN
    RAISE EXCEPTION '%: some attendance should not appear in the query result', _test_case;
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_result) EXCEPT SELECT id FROM vibetype.attendance) THEN
    RAISE EXCEPTION '%: some attendance is missing in the query result', _test_case;
  END IF;

  PERFORM vibetype_test.invoker_set_previous();
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.attendance_test(TEXT, UUID, UUID[]) TO vibetype_account;
