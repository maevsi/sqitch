BEGIN;

CREATE OR REPLACE FUNCTION vibetype_test.account_create (
  _username TEXT,
  _email TEXT
) RETURNS UUID AS $$
DECLARE
  _id UUID;
  _verification UUID;
BEGIN
  _id := vibetype.account_registration(_username, _email, 'password', 'en');

  SELECT email_address_verification INTO _verification
  FROM vibetype_private.account
  WHERE id = _id;

  PERFORM vibetype.account_email_address_verification(_verification);

  RETURN _id;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION vibetype_test.account_remove (
  _username TEXT
) RETURNS VOID AS $$
DECLARE
  _id UUID;
BEGIN
  SELECT id INTO _id FROM vibetype.account WHERE username = _username;

  IF _id IS NOT NULL THEN

    SET LOCAL role = 'vibetype_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _id || '''';

    DELETE FROM vibetype.event WHERE created_by = _id;

    PERFORM vibetype.account_delete('password');

    SET LOCAL role = 'postgres';
  END IF;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION vibetype_test.contact_select_by_account_id (
  _account_id UUID
) RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  SELECT id INTO _id
  FROM vibetype.contact
  WHERE created_by = _account_id AND account_id = _account_id;

  RETURN _id;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION vibetype_test.contact_create (
  _created_by UUID,
  _email_address TEXT
) RETURNS UUID AS $$
DECLARE
  _id UUID;
  _account_id UUID;
BEGIN
  SELECT id FROM vibetype_private.account WHERE email_address = _email_address INTO _account_id;

  SET LOCAL role = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _created_by || '''';

  INSERT INTO vibetype.contact(created_by, email_address)
  VALUES (_created_by, _email_address)
  RETURNING id INTO _id;

  IF (_account_id IS NOT NULL) THEN
    UPDATE vibetype.contact SET account_id = _account_id WHERE id = _id;
  END IF;

  SET LOCAL role = 'postgres';

  RETURN _id;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION vibetype_test.event_create (
  _created_by UUID,
  _name TEXT,
  _slug TEXT,
  _start TEXT,
  _visibility TEXT
) RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  SET LOCAL role = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _created_by || '''';

  INSERT INTO vibetype.event(created_by, name, slug, start, visibility)
  VALUES (_created_by, _name, _slug, _start::TIMESTAMP WITH TIME ZONE, _visibility::vibetype.event_visibility)
  RETURNING id INTO _id;

  SET LOCAL role = 'postgres';

  RETURN _id;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION vibetype_test.guest_create (
  _created_by UUID,
  _event_id UUID,
  _contact_id UUID
) RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  SET LOCAL role = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _created_by || '''';

  INSERT INTO vibetype.guest(contact_id, event_id)
  VALUES (_contact_id, _event_id)
  RETURNING id INTO _id;

  SET LOCAL role = 'postgres';

  RETURN _id;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION vibetype_test.event_category_create (
  _category TEXT
) RETURNS VOID AS $$
BEGIN
  INSERT INTO vibetype.event_category(category) VALUES (_category);
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION vibetype_test.event_category_mapping_create (
  _created_by UUID,
  _event_id UUID,
  _category TEXT
) RETURNS VOID AS $$
BEGIN
  SET LOCAL role = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _created_by || '''';

  INSERT INTO vibetype.event_category_mapping(event_id, category)
  VALUES (_event_id, _category);

  SET LOCAL role = 'postgres';
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION vibetype_test.account_block_create (
  _created_by UUID,
  _blocked_account_id UUID
) RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  SET LOCAL role = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _created_by || '''';

  INSERT INTO vibetype.account_block(created_by, blocked_account_id)
  VALUES (_created_by, _blocked_Account_id)
  RETURNING id INTO _id;

  SET LOCAL role = 'postgres';

  RETURN _id;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION vibetype_test.account_block_remove (
  _created_by UUID,
  _blocked_account_id UUID
) RETURNS VOID AS $$
DECLARE
  _id UUID;
BEGIN
  DELETE FROM vibetype.account_block
  WHERE created_by = _created_by  and blocked_account_id = _blocked_account_id;
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION vibetype_test.event_test (
  _test_case TEXT,
  _account_id UUID,
  _expected_result UUID[]
) RETURNS VOID AS $$
BEGIN
  IF _account_id IS NULL THEN
    SET LOCAL role = 'vibetype_anonymous';
    SET LOCAL jwt.claims.account_id = '';
  ELSE
    SET LOCAL role = 'vibetype_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';
  END IF;

  IF EXISTS (SELECT id FROM vibetype.event EXCEPT SELECT * FROM unnest(_expected_result)) THEN
    RAISE EXCEPTION 'some event should not appear in the query result';
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_result) EXCEPT SELECT id FROM vibetype.event) THEN
    RAISE EXCEPTION 'some event is missing in the query result';
  END IF;

  SET LOCAL role = 'postgres';
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION vibetype_test.event_category_mapping_test (
  _test_case TEXT,
  _account_id UUID,
  _expected_result UUID[]
) RETURNS VOID AS $$
BEGIN
  IF _account_id IS NULL THEN
    SET LOCAL role = 'vibetype_anonymous';
    SET LOCAL jwt.claims.account_id = '';
  ELSE
    SET LOCAL role = 'vibetype_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';
  END IF;

  IF EXISTS (SELECT event_id FROM vibetype.event_category_mapping EXCEPT SELECT * FROM unnest(_expected_result)) THEN
    RAISE EXCEPTION 'some event_category_mappings should not appear in the query result';
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_result) EXCEPT SELECT event_id FROM vibetype.event_category_mapping) THEN
    RAISE EXCEPTION 'some event_category_mappings is missing in the query result';
  END IF;

  SET LOCAL role = 'postgres';
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION vibetype_test.contact_test (
  _test_case TEXT,
  _account_id UUID,
  _expected_result UUID[]
) RETURNS VOID AS $$
DECLARE
  rec RECORD;
BEGIN
  IF _account_id IS NULL THEN
    SET LOCAL role = 'vibetype_anonymous';
    SET LOCAL jwt.claims.account_id = '';
  ELSE
    SET LOCAL role = 'vibetype_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';
  END IF;

  IF EXISTS (SELECT id FROM vibetype.contact EXCEPT SELECT * FROM unnest(_expected_result)) THEN
    RAISE EXCEPTION 'some contact should not appear in the query result';
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_result) EXCEPT SELECT id FROM vibetype.contact) THEN
    RAISE EXCEPTION 'some contact is missing in the query result';
  END IF;

  SET LOCAL role = 'postgres';
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION vibetype_test.guest_test (
  _test_case TEXT,
  _account_id UUID,
  _expected_result UUID[]
) RETURNS VOID AS $$
BEGIN
  IF _account_id IS NULL THEN
    SET LOCAL role = 'vibetype_anonymous';
    SET LOCAL jwt.claims.account_id = '';
  ELSE
    SET LOCAL role = 'vibetype_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';
  END IF;

  IF EXISTS (SELECT id FROM vibetype.guest EXCEPT SELECT * FROM unnest(_expected_result)) THEN
    RAISE EXCEPTION 'some guest should not appear in the query result';
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_result) EXCEPT SELECT id FROM vibetype.guest) THEN
    RAISE EXCEPTION 'some guest is missing in the query result';
  END IF;

  SET LOCAL role = 'postgres';
END $$ LANGUAGE plpgsql;

CREATE FUNCTION vibetype_test.guest_claim_from_account_guest (
  _account_id UUID
)
RETURNS UUID[] AS $$
DECLARE
  _guest vibetype.guest;
  _result UUID[] := ARRAY[]::UUID[];
  _text TEXT := '';
BEGIN
  SET LOCAL role = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';

  -- reads all guests where _account_id is invited,
  -- sets jwt.claims.guests to a string representation of these guests
  -- and returns an array of these guests.

  FOR _guest IN
    SELECT g.id
    FROM vibetype.guest g JOIN vibetype.contact c
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

  SET LOCAL role = 'postgres';

  RETURN _result;
END $$ LANGUAGE plpgsql;

CREATE FUNCTION vibetype_test.invoker_set (
  _invoker_id UUID
)
RETURNS VOID AS $$
BEGIN
  SET LOCAL role = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _invoker_id || '''';
END $$ LANGUAGE plpgsql;

CREATE FUNCTION vibetype_test.invoker_unset ()
RETURNS VOID AS $$
BEGIN
  CALL vibetype_test.set_local_superuser();
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''''';
END $$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION vibetype_test.uuid_array_test (
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
