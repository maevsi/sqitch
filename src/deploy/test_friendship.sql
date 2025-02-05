BEGIN;

CREATE OR REPLACE FUNCTION maevsi_test.account_create (
  _username TEXT,
  _email TEXT
) RETURNS UUID AS $$
DECLARE
  _id UUID;
  _verification UUID;
BEGIN
  _id := maevsi.account_registration(_username, _email, 'password', 'en');

  SELECT email_address_verification INTO _verification
  FROM maevsi_private.account
  WHERE id = _id;

  PERFORM maevsi.account_email_address_verification(_verification);

  RETURN _id;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION maevsi_test.friendship_accept (
  _invoker_account_id UUID,
  _id UUID
) RETURNS VOID AS $$
DECLARE
  rec RECORD;
  _count INTEGER;
BEGIN
  RAISE NOTICE 'friendship_accept: _invoker = %, _id = %', _invoker_account_id, _id;

  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _invoker_account_id || '''';

  FOR rec IN
    SELECT * FROM maevsi.friendship WHERE id = _id
  LOOP
	RAISE NOTICE 'friendship: id = %, a_account_id = %, b_account_id = %, status = %, created_by = %, updated_by = %', rec.id, rec.a_account_id, rec.b_account_id, rec.status, rec.created_by, rec.updated_by;
  END LOOP;

  UPDATE maevsi.friendship
  SET "status" = 'accepted'::maevsi.friendship_status
  WHERE id = _id;

  GET DIAGNOSTICS _count = ROW_COUNT;
  RAISE NOTICE '#updated = %', _count;

  SET LOCAL role = 'postgres';

END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION maevsi_test.friendship_reject (
  _invoker_account_id UUID,
  _id UUID
) RETURNS VOID AS $$
BEGIN

  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _invoker_account_id || '''';

  UPDATE maevsi.friendship SET
    status = 'rejected'::maevsi.friendship_status
  WHERE id = _id;

  SET LOCAL role = 'postgres';

END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION maevsi_test.friendship_request (
  _invoker_account_id UUID,
  _friend_account_id UUID
) RETURNS UUID AS $$
DECLARE
  _id UUID;
  _a_account_id UUID;
  _b_account_id UUID;
BEGIN

  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _invoker_account_id || '''';

  IF _invoker_account_id < _friend_account_id THEN
    _a_account_id := _invoker_account_id;
    _b_account_id := _friend_account_id;
  ELSE
    _a_account_id := _friend_account_id;
    _b_account_id := _invoker_account_id;
  END IF;

  INSERT INTO maevsi.friendship(a_account_id, b_account_id, created_by)
  VALUES (_a_account_id, _b_account_id, _invoker_account_id)
  RETURNING id INTO _id;

  SET LOCAL role = 'postgres';

  RETURN _id;

END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION maevsi_test.friendship_test (
  _test_case TEXT,
  _invoker_account_id UUID,
  _status TEXT,
  _expected_result UUID[]
) RETURNS VOID AS $$
DECLARE
  rec RECORD;
BEGIN

  RAISE NOTICE '%', _test_case;

  IF _invoker_account_id IS NULL THEN
    SET LOCAL role = 'maevsi_anonymous';
    SET LOCAL jwt.claims.account_id = '';
  ELSE
    SET LOCAL role = 'maevsi_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _invoker_account_id || '''';
  END IF;

  IF EXISTS (
    SELECT id FROM maevsi.friendship WHERE status = _status::maevsi.friendship_status
    EXCEPT
    SELECT * FROM unnest(_expected_result)
  ) THEN
    RAISE EXCEPTION 'some accounts should not appear in the query result';
  END IF;

  IF EXISTS (
    SELECT * FROM unnest(_expected_result)
    EXCEPT
    SELECT id FROM maevsi.friendship WHERE status = _status::maevsi.friendship_status
  ) THEN
    RAISE EXCEPTION 'some account is missing in the query result';
  END IF;

  SET LOCAL role = 'postgres';
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION maevsi_test.friendship_account_ids_test (
  _test_case TEXT,
  _invoker_account_id UUID,
  _expected_result UUID[]
) RETURNS VOID AS $$
DECLARE
  rec RECORD;
BEGIN

  RAISE NOTICE '%', _test_case;

  IF _invoker_account_id IS NULL THEN
    SET LOCAL role = 'maevsi_anonymous';
    SET LOCAL jwt.claims.account_id = '';
  ELSE
    SET LOCAL role = 'maevsi_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _invoker_account_id || '''';
  END IF;

  IF EXISTS (
    SELECT id FROM maevsi.friendship_account_ids()
    EXCEPT
    SELECT * FROM unnest(_expected_result)
  ) THEN
    RAISE EXCEPTION 'some accounts should not appear in the list of friends';
  END IF;

  IF EXISTS (
    SELECT * FROM unnest(_expected_result)
    EXCEPT
    SELECT id FROM maevsi.friendship_account_ids()
  ) THEN
    RAISE EXCEPTION 'some account is missing in the list of friends';
  END IF;

  SET LOCAL role = 'postgres';
END $$ LANGUAGE plpgsql;

END;
