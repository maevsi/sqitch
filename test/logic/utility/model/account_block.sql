CREATE OR REPLACE FUNCTION vibetype_test.account_block_create (
  _created_by UUID,
  _blocked_account_id UUID
) RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  PERFORM vibetype_test.invoker_set(_created_by);

  INSERT INTO vibetype.account_block(created_by, blocked_account_id)
  VALUES (_created_by, _blocked_Account_id)
  RETURNING id INTO _id;

  PERFORM vibetype_test.invoker_set_previous();

  RETURN _id;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.account_block_create(UUID, UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.account_block_delete (
  _created_by UUID,
  _blocked_account_id UUID
) RETURNS VOID AS $$
DECLARE
  _id UUID;
BEGIN
  DELETE FROM vibetype.account_block
  WHERE created_by = _created_by AND blocked_account_id = _blocked_account_id;
END $$ LANGUAGE plpgsql STRICT SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION vibetype_test.account_block_delete(UUID, UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.account_block_accounts_test(
  _test_case TEXT,
  _invoker_account_id UUID,
  _account_id UUID,
  _assert_is_visible BOOLEAN
) RETURNS VOID AS $$
DECLARE
  _result BOOLEAN;
BEGIN
  PERFORM vibetype_test.invoker_set(_invoker_account_id);

  SELECT true INTO _result
  FROM vibetype.account_block_accounts()
  WHERE id = _account_id;

  IF _result IS NULL AND _assert_is_visible THEN
    RAISE EXCEPTION '%: account % should be visible but is not.', _test_case, _account_id;
  END IF;

  IF _result AND NOT _assert_is_visible THEN
    RAISE EXCEPTION '%: account % is visible but should not.', _test_case, _account_id;
  END IF;

  PERFORM vibetype_test.invoker_set_previous();
END;
$$ LANGUAGE plpgsql STRICT SECURITY INVOKER;

GRANT EXECUTE ON FUNCTION vibetype_test.account_block_accounts_test(TEXT, UUID, UUID, BOOLEAN) TO vibetype_account;
