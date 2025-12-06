CREATE OR REPLACE FUNCTION vibetype_test.contact_select_by_account_id (
  _account_id UUID
) RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  PERFORM vibetype_test.invoker_set(_account_id);

  SELECT id INTO _id
  FROM vibetype.contact
  WHERE created_by = _account_id AND account_id = _account_id;

  PERFORM vibetype_test.invoker_set_previous();

  RETURN _id;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.contact_select_by_account_id(UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.contact_create (
  _invoker_id UUID,
  _email_address TEXT
) RETURNS UUID AS $$
DECLARE
  _id UUID;
  _account_id UUID;
BEGIN
  PERFORM vibetype_test.invoker_set(_invoker_id);

  INSERT INTO vibetype.contact(created_by, email_address)
  VALUES (_invoker_id, _email_address)
  RETURNING id INTO _id;

  _account_id := vibetype_test.account_select_by_email_address(_email_address);

  IF (_account_id IS NOT NULL) THEN
    UPDATE vibetype.contact SET account_id = _account_id WHERE id = _id;
  END IF;

  PERFORM vibetype_test.invoker_set_previous();

  RETURN _id;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.contact_create(UUID, TEXT) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.contact_test (
  _test_case TEXT,
  _account_id UUID,
  _expected_result UUID[]
) RETURNS VOID AS $$
DECLARE
  rec RECORD;
BEGIN
  IF _account_id IS NULL THEN
    PERFORM vibetype_test.invoker_set_anonymous();
  ELSE
    PERFORM vibetype_test.invoker_set(_account_id);
  END IF;

  IF EXISTS (SELECT id FROM vibetype.contact EXCEPT SELECT * FROM unnest(_expected_result)) THEN
    RAISE EXCEPTION '%: some contact should not appear in the query result', _test_case;
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_result) EXCEPT SELECT id FROM vibetype.contact) THEN
    RAISE EXCEPTION '%: some contact is missing in the query result', _test_case;
  END IF;

  PERFORM vibetype_test.invoker_set_previous();
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.contact_test(TEXT, UUID, UUID[]) TO vibetype_account;
