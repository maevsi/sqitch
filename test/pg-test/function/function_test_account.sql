CREATE FUNCTION vibetype_test.account_registration_verified (
  _username TEXT,
  _email_address TEXT
) RETURNS UUID AS $$
DECLARE
  _account_id UUID;
  _legal_term_id UUID;
  _verification UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_singleton();
  PERFORM vibetype.account_registration(_email_address, 'en', _legal_term_id, 'password', _username);

  SELECT id INTO _account_id
  FROM vibetype.account
  WHERE username = _username;

  SELECT email_address_verification INTO _verification
  FROM vibetype_private.account
  WHERE id = _account_id;

  PERFORM vibetype.account_email_address_verification(_verification);

  RETURN _account_id;
END $$ LANGUAGE plpgsql STRICT SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION vibetype_test.account_registration_verified(TEXT, TEXT) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.account_remove (
  _username TEXT
) RETURNS VOID AS $$
DECLARE
  _id UUID;
BEGIN
  SELECT id INTO _id FROM vibetype.account WHERE username = _username;

  IF _id IS NOT NULL THEN

    SET LOCAL ROLE = 'vibetype_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _id || '''';

    DELETE FROM vibetype.event WHERE created_by = _id;

    PERFORM vibetype.account_delete('password');

    SET LOCAL ROLE NONE;
  END IF;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.account_remove(TEXT) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.account_select_by_email_address(_email_address text)
RETURNS UUID AS $$
DECLARE
  _account_id UUID;
BEGIN
  SELECT id
  INTO _account_id
  FROM vibetype_private.account
  WHERE email_address = _email_address;

  RETURN _account_id;
END;
$$ LANGUAGE plpgsql STRICT SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION vibetype_test.account_select_by_email_address(TEXT) TO vibetype_account;


CREATE FUNCTION vibetype_test.legal_term_singleton ()
RETURNS UUID AS $$
DECLARE
  _id UUID;
  _verification UUID;
BEGIN
  SELECT id INTO _id FROM vibetype.legal_term LIMIT 1;

  IF (_id IS NULL) THEN
    INSERT INTO vibetype.legal_term (term, version) VALUES ('Be excellent to each other', '0.0.0')
      RETURNING id INTO _id;
  END IF;

  RETURN _id;
END $$ LANGUAGE plpgsql STRICT SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION vibetype_test.legal_term_singleton() TO vibetype_account, vibetype_anonymous;