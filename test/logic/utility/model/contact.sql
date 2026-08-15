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


-- SECURITY DEFINER so tests can resolve-or-create vibetype_private.email_address/subject rows
-- without needing direct grants there; kept separate from contact_create since Postgres forbids
-- SET ROLE (which vibetype_test.invoker_set does) anywhere in a security-definer call stack.
CREATE OR REPLACE FUNCTION vibetype_test.email_address_resolve_or_create (
  _email_address TEXT
) RETURNS UUID
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  _email_address_id UUID;
  _subject_id UUID;
BEGIN
  SELECT id INTO _email_address_id FROM vibetype_private.email_address WHERE address = _email_address;

  IF (_email_address_id IS NULL) THEN
    INSERT INTO vibetype_private.subject DEFAULT VALUES RETURNING id INTO _subject_id;
    INSERT INTO vibetype_private.email_address (subject_id, address) VALUES (_subject_id, _email_address)
      RETURNING id INTO _email_address_id;
  END IF;

  RETURN _email_address_id;
END $$;

GRANT EXECUTE ON FUNCTION vibetype_test.email_address_resolve_or_create(TEXT) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.contact_create (
  _invoker_id UUID,
  _email_address TEXT
) RETURNS UUID AS $$
DECLARE
  _id UUID;
  _account_id UUID;
  _email_address_id UUID;
BEGIN
  _email_address_id := vibetype_test.email_address_resolve_or_create(_email_address);

  PERFORM vibetype_test.invoker_set(_invoker_id);

  INSERT INTO vibetype.contact(created_by)
  VALUES (_invoker_id)
  RETURNING id INTO _id;

  INSERT INTO vibetype.contact_email_address (contact_id, email_address_id) VALUES (_id, _email_address_id);

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
