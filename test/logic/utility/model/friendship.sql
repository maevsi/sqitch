CREATE OR REPLACE FUNCTION vibetype_test.friendship_accept (
  _invoker_account_id UUID,
  _id UUID
) RETURNS VOID AS $$
DECLARE
  rec RECORD;
  _count INTEGER;
BEGIN
  PERFORM vibetype_test.invoker_set(_invoker_account_id);

  UPDATE vibetype.friendship
    SET "status" = 'accepted'::vibetype.friendship_status
    WHERE id = _id;

  PERFORM vibetype_test.invoker_set_previous();
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.friendship_accept(UUID, UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.friendship_reject (
  _invoker_account_id UUID,
  _id UUID
) RETURNS VOID AS $$
BEGIN
  PERFORM vibetype_test.invoker_set(_invoker_account_id);

  DELETE FROM vibetype.friendship
    WHERE id = _id;

  PERFORM vibetype_test.invoker_set_previous();
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.friendship_reject(UUID, UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.friendship_request (
  _invoker_account_id UUID,
  _friend_account_id UUID
) RETURNS UUID AS $$
DECLARE
  _id UUID;
  _a_account_id UUID;
  _b_account_id UUID;
BEGIN
  PERFORM vibetype_test.invoker_set(_invoker_account_id);

  IF _invoker_account_id < _friend_account_id THEN
    _a_account_id := _invoker_account_id;
    _b_account_id := _friend_account_id;
  ELSE
    _a_account_id := _friend_account_id;
    _b_account_id := _invoker_account_id;
  END IF;

  INSERT INTO vibetype.friendship(a_account_id, b_account_id, created_by)
    VALUES (_a_account_id, _b_account_id, _invoker_account_id)
    RETURNING id INTO _id;

  PERFORM vibetype_test.invoker_set_previous();

  RETURN _id;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.friendship_request(UUID, UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.friendship_test (
  _test_case TEXT,
  _invoker_account_id UUID,
  _status TEXT, -- status IS NULL means "any status"
  _expected_result UUID[]
) RETURNS VOID AS $$
DECLARE
  rec RECORD;
BEGIN
  IF _invoker_account_id IS NULL THEN
    PERFORM vibetype_test.invoker_set_anonymous();
  ELSE
    PERFORM vibetype_test.invoker_set(_invoker_account_id);
  END IF;

  IF EXISTS (
    SELECT id FROM vibetype.friendship WHERE _status IS NULL OR status = _status::vibetype.friendship_status
    EXCEPT
    SELECT * FROM unnest(_expected_result)
  ) THEN
    RAISE EXCEPTION 'some accounts should not appear in the query result';
  END IF;

  IF EXISTS (
    SELECT * FROM unnest(_expected_result)
    EXCEPT
    SELECT id FROM vibetype.friendship WHERE _status IS NULL OR status = _status::vibetype.friendship_status
  ) THEN
    RAISE EXCEPTION 'some account is missing in the query result';
  END IF;

  PERFORM vibetype_test.invoker_set_previous();
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.friendship_test(TEXT, UUID, TEXT, UUID[]) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.friendship_account_ids_test (
  _test_case TEXT,
  _invoker_account_id UUID,
  _expected_result UUID[]
) RETURNS VOID AS $$
DECLARE
  rec RECORD;
BEGIN
  IF _invoker_account_id IS NULL THEN
    PERFORM set_config('jwt.claims.account_id', '', true);
  ELSE
    PERFORM set_config('jwt.claims.account_id', _invoker_account_id::TEXT, true);
  END IF;

  IF EXISTS (
    WITH friendship_account_ids_test AS (
      SELECT b_account_id as account_id
      FROM vibetype.friendship
      WHERE a_account_id = _invoker_account_id
        and status = 'accepted'::vibetype.friendship_status
      UNION ALL
      SELECT a_account_id as account_id
      FROM vibetype.friendship
      WHERE b_account_id = _invoker_account_id
        and status = 'accepted'::vibetype.friendship_status
    )
    SELECT account_id as id
    FROM friendship_account_ids_test
    WHERE account_id NOT IN (SELECT b.id FROM vibetype_private.account_block_ids() b)
    EXCEPT
    SELECT * FROM unnest(_expected_result)
  ) THEN
    RAISE EXCEPTION 'some accounts should not appear in the list of friends';
  END IF;

  IF EXISTS (
    WITH friendship_account_ids_test AS (
      SELECT b_account_id as account_id
      FROM vibetype.friendship
      WHERE a_account_id = vibetype.invoker_account_id()
        and status = 'accepted'::vibetype.friendship_status
      UNION ALL
      SELECT a_account_id as account_id
      FROM vibetype.friendship
      WHERE b_account_id = vibetype.invoker_account_id()
        and status = 'accepted'::vibetype.friendship_status
    )
    SELECT * FROM unnest(_expected_result)
    EXCEPT
    SELECT account_id as id
    FROM friendship_account_ids_test
    WHERE account_id NOT IN (SELECT b.id FROM vibetype_private.account_block_ids() b)
  ) THEN
    RAISE EXCEPTION 'some account is missing in the list of friends';
  END IF;
END $$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION vibetype_test.friendship_account_ids_test(TEXT, UUID, UUID[]) TO vibetype_account;
