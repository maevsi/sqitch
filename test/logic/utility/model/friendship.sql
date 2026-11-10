CREATE OR REPLACE FUNCTION vibetype_test.friendship_accept (
  _invoker_account_id UUID,
  _id UUID
) RETURNS INTEGER AS $$
DECLARE
  _count INTEGER;
BEGIN
  PERFORM vibetype_test.invoker_set(_invoker_account_id);

  UPDATE vibetype.friendship
    SET status = 'accepted'::vibetype.friendship_status
    WHERE id = _id;

  GET DIAGNOSTICS _count = ROW_COUNT;

  PERFORM vibetype_test.invoker_set_previous();

  RETURN _count;
END $$ LANGUAGE plpgsql;

COMMENT ON FUNCTION vibetype_test.friendship_accept(UUID, UUID) IS 'Accepts a friendship as the given account and returns the number of updated rows, which is zero when row level security hides the friendship from the update.';

GRANT EXECUTE ON FUNCTION vibetype_test.friendship_accept(UUID, UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.friendship_create (
  _invoker_account_id UUID,
  _friend_account_id UUID
) RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  PERFORM vibetype_test.invoker_set(_invoker_account_id);

  INSERT INTO vibetype.friendship(account_a_id, account_b_id, created_by)
    VALUES (
      LEAST(_invoker_account_id, _friend_account_id),
      GREATEST(_invoker_account_id, _friend_account_id),
      _invoker_account_id
    )
    RETURNING id INTO _id;

  PERFORM vibetype_test.invoker_set_previous();

  RETURN _id;
END $$ LANGUAGE plpgsql;

COMMENT ON FUNCTION vibetype_test.friendship_create(UUID, UUID) IS 'Requests a friendship with the given friend as the given account.';

GRANT EXECUTE ON FUNCTION vibetype_test.friendship_create(UUID, UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.friendship_create_accepted (
  _invoker_account_id UUID,
  _friend_account_id UUID
) RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  _id := vibetype_test.friendship_create(_invoker_account_id, _friend_account_id);
  PERFORM vibetype_test.friendship_accept(_friend_account_id, _id);

  RETURN _id;
END $$ LANGUAGE plpgsql;

COMMENT ON FUNCTION vibetype_test.friendship_create_accepted(UUID, UUID) IS 'Requests a friendship as the given account and accepts it as the given friend.';

GRANT EXECUTE ON FUNCTION vibetype_test.friendship_create_accepted(UUID, UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.friendship_delete (
  _invoker_account_id UUID,
  _id UUID
) RETURNS INTEGER AS $$
DECLARE
  _count INTEGER;
BEGIN
  PERFORM vibetype_test.invoker_set(_invoker_account_id);

  DELETE FROM vibetype.friendship
    WHERE id = _id;

  GET DIAGNOSTICS _count = ROW_COUNT;

  PERFORM vibetype_test.invoker_set_previous();

  RETURN _count;
END $$ LANGUAGE plpgsql;

COMMENT ON FUNCTION vibetype_test.friendship_delete(UUID, UUID) IS 'Deletes a friendship as the given account and returns the number of deleted rows, which is zero when row level security hides the friendship from the delete.';

GRANT EXECUTE ON FUNCTION vibetype_test.friendship_delete(UUID, UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.friendship_test (
  _test_case TEXT,
  _invoker_account_id UUID,
  _status TEXT, -- NULL means "any status"; text as the cleanup drops functions without qualifying argument types
  _expected_result UUID[]
) RETURNS VOID AS $$
DECLARE
  _result UUID[];
BEGIN
  PERFORM vibetype_test.invoker_set(_invoker_account_id);

  SELECT COALESCE(array_agg(id), ARRAY[]::UUID[]) INTO _result
    FROM vibetype.friendship
    WHERE _status IS NULL OR status = _status::vibetype.friendship_status;

  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.uuid_array_test(_test_case, _result, _expected_result);
END $$ LANGUAGE plpgsql;

COMMENT ON FUNCTION vibetype_test.friendship_test(TEXT, UUID, TEXT, UUID[]) IS 'Asserts that the given account sees exactly the expected friendships of the given status.';

GRANT EXECUTE ON FUNCTION vibetype_test.friendship_test(TEXT, UUID, TEXT, UUID[]) TO vibetype_account;
