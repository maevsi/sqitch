BEGIN;

CREATE OR REPLACE FUNCTION maevsi_test.create_account (
  _username TEXT,
  _email TEXT)
RETURNS UUID AS $$
DECLARE
  _id UUID;
  _verification UUID;
BEGIN
  _id := maevsi.account_registration(_username, _email, 'abcd1234', 'de');

  SELECT email_address_verification INTO _verification
  FROM maevsi_private.account
  WHERE id = _id;

  PERFORM maevsi.account_email_address_verification(_verification);

  RETURN _id;
END $$ LANGUAGE plpgsql;

-------------------------------------------------

CREATE OR REPLACE FUNCTION maevsi_test.remove_account (
  _username TEXT)
RETURNS VOID AS $$
DECLARE
  _id UUID;
BEGIN

  SELECT id INTO _id FROM maevsi.account WHERE username = _username;

  IF _id IS NOT NULL THEN

    SET LOCAL role = 'maevsi_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _id || '''';

    DELETE FROM maevsi.event WHERE author_account_id = _id;

    PERFORM maevsi.account_delete('abcd1234');

    SET LOCAL role = 'postgres';

  END IF;
END $$ LANGUAGE plpgsql;

-------------------------------------------------

CREATE OR REPLACE FUNCTION maevsi_test.get_own_contact (
  _account_id UUID)
RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  SELECT id INTO _id
  FROM maevsi.contact
  WHERE author_account_id = _account_id AND account_id = _account_id;

  RAISE NOTICE '_account_id = %, _id = %', _account_id, _id;

  RETURN _id;
END $$ LANGUAGE plpgsql;

-------------------------------------------------

CREATE OR REPLACE FUNCTION maevsi_test.create_contact (
  _author_account_id UUID,
  _email_address TEXT)
RETURNS UUID AS $$
DECLARE
  _id UUID;
  _account_id UUID;
BEGIN

  SELECT id FROM maevsi_private.account WHERE email_address = _email_address INTO _account_id;

  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _author_account_id || '''';

  INSERT INTO maevsi.contact(author_account_id, email_address)
  VALUES (_author_account_id, _email_address)
  RETURNING id INTO _id;

  IF (_account_id IS NOT NULL) THEN
    UPDATE maevsi.contact SET account_id = _account_id WHERE id = _id;
  END IF;

  SET LOCAL role = 'postgres';

  RETURN _id;
END $$ LANGUAGE plpgsql;

-------------------------------------------------

CREATE OR REPLACE FUNCTION maevsi_test.create_event (
  _author_account_id UUID,
  _name TEXT,
  _slug TEXT,
  _start TEXT, -- format: 'YYYY-MM-DD HH24:MI'
  _visibility TEXT)
RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _author_account_id || '''';

  INSERT INTO maevsi.event(author_account_id, name, slug, start, visibility)
  VALUES (_author_account_id, _name, _slug, to_timestamp(_start, 'YYYY-MM-DD HH24:MI'), _visibility::maevsi.event_visibility)
  RETURNING id INTO _id;

  SET LOCAL role = 'postgres';

  RETURN _id;
END $$ LANGUAGE plpgsql;

-------------------------------------------------

CREATE OR REPLACE FUNCTION maevsi_test.create_invitation (
  _author_account_id UUID,
  _event_id UUID,
  _contact_id UUID)
RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _author_account_id || '''';

  INSERT INTO maevsi.invitation(contact_id, event_id)
  VALUES (_contact_id, _event_id)
  RETURNING id INTO _id;

  SET LOCAL role = 'postgres';

  RETURN _id;
END $$ LANGUAGE plpgsql;

-------------------------------------------------

CREATE OR REPLACE FUNCTION maevsi_test.create_event_category (
  _category TEXT)
RETURNS VOID AS $$
BEGIN

  INSERT INTO maevsi.event_category(category) VALUES (_category);

END $$ LANGUAGE plpgsql;

-------------------------------------------------

CREATE OR REPLACE FUNCTION maevsi_test.create_event_category_mapping (
  _author_account_id UUID,
  _event_id UUID,
  _category TEXT)
RETURNS VOID AS $$
BEGIN
  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _author_account_id || '''';

  INSERT INTO maevsi.event_category_mapping(event_id, category)
  VALUES (_event_id, _category);

  SET LOCAL role = 'postgres';

END $$ LANGUAGE plpgsql;

-------------------------------------------------

CREATE OR REPLACE FUNCTION maevsi_test.block_account (
  _author_account_id UUID,
  _blocked_account_id UUID)
RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _author_account_id || '''';

  INSERT INTO maevsi.account_block(author_account_id, blocked_account_id)
  VALUES (_author_account_id, _blocked_Account_id)
  RETURNING id INTO _id;

  SET LOCAL role = 'postgres';

  RETURN _id;
END $$ LANGUAGE plpgsql;

-------------------------------------------------

CREATE OR REPLACE FUNCTION maevsi_test.unblock_account (
  _author_account_id UUID,
  _blocked_account_id UUID)
RETURNS VOID AS $$
DECLARE
  _id UUID;
BEGIN
  DELETE FROM maevsi.account_block
  WHERE author_account_id = _author_account_id  and blocked_account_id = _blocked_account_id;
END $$ LANGUAGE plpgsql;

-------------------------------------------------

CREATE OR REPLACE FUNCTION maevsi_test.select_events (
  _test_case TEXT,
  _description TEXT,
  _account_id UUID,
  _expected_result UUID[]
)
RETURNS VOID AS $$
BEGIN
  RAISE NOTICE '%: %', _test_case, _description;

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

  SET LOCAL role = 'postgres';

END $$ LANGUAGE plpgsql;

-------------------------------------------------

CREATE OR REPLACE FUNCTION maevsi_test.select_event_category_mappings (
  _test_case TEXT,
  _description TEXT,
  _account_id UUID,
  _expected_result UUID[]
)
RETURNS VOID AS $$
BEGIN
  RAISE NOTICE '%: %', _test_case, _description;

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

  SET LOCAL role = 'postgres';

END $$ LANGUAGE plpgsql;

-------------------------------------------------

CREATE OR REPLACE FUNCTION maevsi_test.select_contacts (
  _test_case TEXT,
  _description TEXT,
  _account_id UUID,
  _expected_result UUID[]
)
RETURNS VOID AS $$
DECLARE
  rec RECORD;
BEGIN
  RAISE NOTICE '%: %', _test_case, _description;

  IF _account_id IS NULL THEN
    SET LOCAL role = 'maevsi_anonymous';
    SET LOCAL jwt.claims.account_id = '';
  ELSE
    SET LOCAL role = 'maevsi_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';
  END IF;

  FOR rec IN
    SELECT id FROM maevsi.contact
  LOOP
    RAISE NOTICE '%', rec.id;
  END LOOP;

  IF EXISTS (SELECT id FROM maevsi.contact EXCEPT SELECT * FROM unnest(_expected_result)) THEN
    RAISE EXCEPTION 'some contact should not appear in the query result';
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_result) EXCEPT SELECT id FROM maevsi.contact) THEN
    RAISE EXCEPTION 'some contact is missing in the query result';
  END IF;

  SET LOCAL role = 'postgres';

END $$ LANGUAGE plpgsql;

-------------------------------------------------

CREATE OR REPLACE FUNCTION maevsi_test.select_invitations (
  _test_case TEXT,
  _description TEXT,
  _account_id UUID,
  _expected_result UUID[]
)
RETURNS VOID AS $$
BEGIN
  RAISE NOTICE '%: %', _test_case, _description;

  IF _account_id IS NULL THEN
    SET LOCAL role = 'maevsi_anonymous';
    SET LOCAL jwt.claims.account_id = '';
  ELSE
    SET LOCAL role = 'maevsi_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';
  END IF;

  IF EXISTS (SELECT id FROM maevsi.invitation EXCEPT SELECT * FROM unnest(_expected_result)) THEN
    RAISE EXCEPTION 'some invitation should not appear in the query result';
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_result) EXCEPT SELECT id FROM maevsi.invitation) THEN
    RAISE EXCEPTION 'some invitation is missing in the query result';
  END IF;

  SET LOCAL role = 'postgres';

END $$ LANGUAGE plpgsql;

-------------------------------------------------

COMMIT; -- test functions
