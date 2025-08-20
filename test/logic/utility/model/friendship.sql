CREATE OR REPLACE FUNCTION vibetype_test.friendship_accept (
  _invoker_account_id UUID,
  _requestor_account_id UUID
) RETURNS VOID AS $$
DECLARE
  rec RECORD;
  _count INTEGER;
BEGIN
  SET LOCAL role = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _invoker_account_id || '''';

  PERFORM vibetype.friendship_accept(_requestor_account_id);

  SET LOCAL ROLE NONE;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.friendship_accept(UUID, UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.friendship_cancel (
  _invoker_account_id UUID,
  _friend_account_id UUID
) RETURNS VOID AS $$
BEGIN
  SET LOCAL role = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _invoker_account_id || '''';

  PERFORM vibetype.friendship_cancel(_friend_account_id);

  SET LOCAL ROLE NONE;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.friendship_cancel(UUID, UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.friendship_reject (
  _invoker_account_id UUID,
  _friend_account_id UUID
) RETURNS VOID AS $$
BEGIN
  SET LOCAL role = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _invoker_account_id || '''';

  PERFORM vibetype.friendship_reject(_friend_account_id);

  SET LOCAL ROLE NONE;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.friendship_reject(UUID, UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.friendship_request (
  _invoker_account_id UUID,
  _friend_account_id UUID
) RETURNS VOID AS $$
BEGIN
  SET LOCAL role = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _invoker_account_id || '''';

  PERFORM vibetype.friendship_request(_friend_account_id);

  SET LOCAL ROLE NONE;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.friendship_request(UUID, UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.friendship_toggle_closeness (
  _invoker_account_id UUID,
  _friend_account_id UUID
) RETURNS VOID AS $$
BEGIN
  SET LOCAL role = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _invoker_account_id || '''';

  PERFORM vibetype.friendship_toggle_closeness(_friend_account_id);

  SET LOCAL ROLE NONE;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.friendship_toggle_closeness(UUID, UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.friendship_test (
  _test_case TEXT,
  _invoker_account_id UUID,
  _account_id UUID,
  _friend_account_id UUID,  -- _friend_account_id IS NULL means "any friend"
  _expected_result BOOLEAN
) RETURNS VOID AS $$
DECLARE
  _result BOOLEAN;
BEGIN
  SET LOCAL role = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _invoker_account_id || '''';

  SELECT TRUE INTO _result
  FROM vibetype.friendship
  WHERE account_id = _account_id
    AND friend_account_id = _friend_account_id;

  IF _result IS NULL THEN
    _result := FALSE;
  END IF;

  IF _result != _expected_result THEN
    RAISE EXCEPTION '%: expected result was % but result is %.', _test_case, _expected_result, _result USING ERRCODE = 'VTTST';
  END IF;

  SET LOCAL ROLE NONE;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.friendship_test(TEXT, UUID, UUID, UUID, BOOLEAN) TO vibetype_account;

CREATE OR REPLACE FUNCTION vibetype_test.friendship_closeness_test (
  _test_case TEXT,
  _invoker_account_id UUID,
  _account_id UUID,
  _friend_account_id UUID,
  _expected_result BOOLEAN
) RETURNS VOID AS $$
DECLARE
  _result BOOLEAN;
BEGIN
  SET LOCAL role = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _invoker_account_id || '''';

  SELECT is_close_friend INTO _result
  FROM vibetype.friendship_closeness
  WHERE account_id = _account_id
    AND friend_account_id = _friend_account_id;

  IF _result != _expected_result THEN
    RAISE EXCEPTION '%: expected result was % but result is %.', _test_case, _expected_result, _result USING ERRCODE = 'VTFCT';
  END IF;

  SET LOCAL ROLE NONE;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.friendship_closeness_test(TEXT, UUID, UUID, UUID, BOOLEAN) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.friendship_request_test (
  _test_case TEXT,
  _invoker_account_id UUID,
  _account_id UUID,
  _friend_account_id UUID,
  _expected_to_exist BOOLEAN
) RETURNS VOID AS $$
DECLARE
  _id UUID;
BEGIN
  SET LOCAL role = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _invoker_account_id || '''';

  SELECT id INTO _id
  FROM vibetype.friendship_request
  WHERE account_id = _account_id
    AND friend_account_id = _friend_account_id;

  IF _id IS NULL AND _expected_to_exist THEN
    RAISE EXCEPTION '%: friendship request expected to exist but not present.', _test_case USING ERRCODE = 'VTFRT';
  END IF;

  IF _id IS NOT NULL AND NOT _expected_to_exist THEN
    RAISE EXCEPTION '%: friendship request exists but is not expected to exist.', _test_case USING ERRCODE = 'VTFRT';
  END IF;

  SET LOCAL ROLE NONE;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.friendship_request_test(TEXT, UUID, UUID, UUID, BOOLEAN) TO vibetype_account;
