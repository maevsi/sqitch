BEGIN;

CREATE PROCEDURE maevsi_test.set_local_superuser()
AS $$
DECLARE
  _superuser_name TEXT;
BEGIN
  SELECT usename INTO _superuser_name
  FROM pg_user
  WHERE usesuper = true
  ORDER BY usename
  LIMIT 1;

  IF _superuser_name IS NOT NULL THEN
    EXECUTE format('SET LOCAL role = %I', _superuser_name);
  ELSE
    RAISE NOTICE 'No superuser found!';
  END IF;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON PROCEDURE maevsi_test.set_local_superuser() TO maevsi_anonymous, maevsi_account;


CREATE FUNCTION maevsi_test.account_create (
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

CREATE FUNCTION maevsi_test.account_remove (
  _username TEXT
) RETURNS VOID AS $$
DECLARE
  _id UUID;
BEGIN
  SELECT id INTO _id FROM maevsi.account WHERE username = _username;

  IF _id IS NOT NULL THEN

    SET LOCAL role = 'maevsi_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _id || '''';

    DELETE FROM maevsi.event WHERE created_by = _id;

    PERFORM maevsi.account_delete('password');

    CALL maevsi_test.set_local_superuser();
  END IF;
END $$ LANGUAGE plpgsql;

CREATE FUNCTION maevsi_test.contact_select_by_account_id (
  _account_id UUID
) RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  SELECT id INTO _id
  FROM maevsi.contact
  WHERE created_by = _account_id AND account_id = _account_id;

  RETURN _id;
END $$ LANGUAGE plpgsql;

CREATE FUNCTION maevsi_test.contact_create (
  _created_by UUID,
  _email_address TEXT
) RETURNS UUID AS $$
DECLARE
  _id UUID;
  _account_id UUID;
BEGIN
  SELECT id FROM maevsi_private.account WHERE email_address = _email_address INTO _account_id;

  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _created_by || '''';

  INSERT INTO maevsi.contact(created_by, email_address)
  VALUES (_created_by, _email_address)
  RETURNING id INTO _id;

  IF (_account_id IS NOT NULL) THEN
    UPDATE maevsi.contact SET account_id = _account_id WHERE id = _id;
  END IF;

  CALL maevsi_test.set_local_superuser();

  RETURN _id;
END $$ LANGUAGE plpgsql;

CREATE FUNCTION maevsi_test.event_create (
  _created_by UUID,
  _name TEXT,
  _slug TEXT,
  _start TEXT,
  _visibility TEXT
) RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _created_by || '''';

  INSERT INTO maevsi.event(created_by, name, slug, start, visibility)
  VALUES (_created_by, _name, _slug, _start::TIMESTAMP WITH TIME ZONE, _visibility::maevsi.event_visibility)
  RETURNING id INTO _id;

  CALL maevsi_test.set_local_superuser();

  RETURN _id;
END $$ LANGUAGE plpgsql;

CREATE FUNCTION maevsi_test.guest_create (
  _created_by UUID,
  _event_id UUID,
  _contact_id UUID
) RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _created_by || '''';

  INSERT INTO maevsi.guest(contact_id, event_id)
  VALUES (_contact_id, _event_id)
  RETURNING id INTO _id;

  CALL maevsi_test.set_local_superuser();

  RETURN _id;
END $$ LANGUAGE plpgsql;

CREATE FUNCTION maevsi_test.event_category_create (
  _category TEXT
) RETURNS VOID AS $$
BEGIN
  INSERT INTO maevsi.event_category(category) VALUES (_category);
END $$ LANGUAGE plpgsql;

CREATE FUNCTION maevsi_test.event_category_mapping_create (
  _created_by UUID,
  _event_id UUID,
  _category TEXT
) RETURNS VOID AS $$
BEGIN
  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _created_by || '''';

  INSERT INTO maevsi.event_category_mapping(event_id, category)
  VALUES (_event_id, _category);

  CALL maevsi_test.set_local_superuser();
END $$ LANGUAGE plpgsql;

CREATE FUNCTION maevsi_test.account_block_create (
  _created_by UUID,
  _blocked_account_id UUID
) RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _created_by || '''';

  INSERT INTO maevsi.account_block(created_by, blocked_account_id)
  VALUES (_created_by, _blocked_Account_id)
  RETURNING id INTO _id;

  CALL maevsi_test.set_local_superuser();

  RETURN _id;
END $$ LANGUAGE plpgsql;

CREATE FUNCTION maevsi_test.account_block_remove (
  _created_by UUID,
  _blocked_account_id UUID
) RETURNS VOID AS $$
DECLARE
  _id UUID;
BEGIN
  DELETE FROM maevsi.account_block
  WHERE created_by = _created_by  and blocked_account_id = _blocked_account_id;
END $$ LANGUAGE plpgsql;

CREATE FUNCTION maevsi_test.event_test (
  _test_case TEXT,
  _account_id UUID,
  _expected_result UUID[]
) RETURNS VOID AS $$
BEGIN
  IF _account_id IS NULL THEN
    SET LOCAL role = 'maevsi_anonymous';
    SET LOCAL jwt.claims.account_id = '';
  ELSE
    SET LOCAL role = 'maevsi_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';
  END IF;

  IF EXISTS (SELECT id FROM maevsi.event EXCEPT SELECT * FROM unnest(_expected_result)) THEN
    RAISE EXCEPTION 'some event should not appear in the query result';
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_result) EXCEPT SELECT id FROM maevsi.event) THEN
    RAISE EXCEPTION 'some event is missing in the query result';
  END IF;

  CALL maevsi_test.set_local_superuser();
END $$ LANGUAGE plpgsql;

CREATE FUNCTION maevsi_test.event_category_mapping_test (
  _test_case TEXT,
  _account_id UUID,
  _expected_result UUID[]
) RETURNS VOID AS $$
BEGIN
  IF _account_id IS NULL THEN
    SET LOCAL role = 'maevsi_anonymous';
    SET LOCAL jwt.claims.account_id = '';
  ELSE
    SET LOCAL role = 'maevsi_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';
  END IF;

  IF EXISTS (SELECT event_id FROM maevsi.event_category_mapping EXCEPT SELECT * FROM unnest(_expected_result)) THEN
    RAISE EXCEPTION 'some event_category_mappings should not appear in the query result';
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_result) EXCEPT SELECT event_id FROM maevsi.event_category_mapping) THEN
    RAISE EXCEPTION 'some event_category_mappings is missing in the query result';
  END IF;

  CALL maevsi_test.set_local_superuser();
END $$ LANGUAGE plpgsql;

CREATE FUNCTION maevsi_test.contact_test (
  _test_case TEXT,
  _account_id UUID,
  _expected_result UUID[]
) RETURNS VOID AS $$
DECLARE
  rec RECORD;
BEGIN
  IF _account_id IS NULL THEN
    SET LOCAL role = 'maevsi_anonymous';
    SET LOCAL jwt.claims.account_id = '';
  ELSE
    SET LOCAL role = 'maevsi_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';
  END IF;

  IF EXISTS (SELECT id FROM maevsi.contact EXCEPT SELECT * FROM unnest(_expected_result)) THEN
    RAISE EXCEPTION 'some contact should not appear in the query result';
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_result) EXCEPT SELECT id FROM maevsi.contact) THEN
    RAISE EXCEPTION 'some contact is missing in the query result';
  END IF;

  CALL maevsi_test.set_local_superuser();
END $$ LANGUAGE plpgsql;

CREATE FUNCTION maevsi_test.guest_test (
  _test_case TEXT,
  _account_id UUID,
  _expected_result UUID[]
) RETURNS VOID AS $$
BEGIN
  IF _account_id IS NULL THEN
    SET LOCAL role = 'maevsi_anonymous';
    SET LOCAL jwt.claims.account_id = '';
  ELSE
    SET LOCAL role = 'maevsi_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';
  END IF;

  IF EXISTS (SELECT id FROM maevsi.guest EXCEPT SELECT * FROM unnest(_expected_result)) THEN
    RAISE EXCEPTION 'some guest should not appear in the query result';
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_result) EXCEPT SELECT id FROM maevsi.guest) THEN
    RAISE EXCEPTION 'some guest is missing in the query result';
  END IF;

  CALL maevsi_test.set_local_superuser();
END $$ LANGUAGE plpgsql;

CREATE FUNCTION maevsi_test.guest_claim_from_account_guest (
  _account_id UUID
)
RETURNS UUID[] AS $$
DECLARE
  _guest maevsi.guest;
  _result UUID[] := ARRAY[]::UUID[];
  _text TEXT := '';
BEGIN
  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';

  -- reads all guests where _account_id is invited,
  -- sets jwt.claims.guests to a string representation of these guests
  -- and returns an array of these guests.

  FOR _guest IN
    SELECT g.id
    FROM maevsi.guest g JOIN maevsi.contact c
      ON g.contact_id = c.id
    WHERE c.account_id = _account_id
  LOOP
    _text := _text || ',"' || _guest.id || '"';
    _result := array_append(_result, _guest.id);
  END LOOP;

  IF LENGTH(_text) > 0 THEN
    _text := SUBSTR(_text, 2);
  END IF;

  EXECUTE 'SET LOCAL jwt.claims.guests = ''[' || _text || ']''';

  CALL maevsi_test.set_local_superuser();

  RETURN _result;
END $$ LANGUAGE plpgsql;

CREATE FUNCTION maevsi_test.uuid_array_test (
  _test_case TEXT,
  _array UUID[],
  _expected_array UUID[]
)
RETURNS VOID AS $$
BEGIN
  IF EXISTS (SELECT * FROM unnest(_array) EXCEPT SELECT * FROM unnest(_expected_array)) THEN
    RAISE EXCEPTION 'some uuid should not appear in the array';
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_array) EXCEPT SELECT * FROM unnest(_array)) THEN
    RAISE EXCEPTION 'some expected uuid is missing in the array';
  END IF;
END $$ LANGUAGE plpgsql;

COMMIT;
