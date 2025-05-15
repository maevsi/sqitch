CREATE FUNCTION vibetype_test.account_registration_verified (
  _username TEXT,
  _email_address TEXT
) RETURNS UUID AS $$
DECLARE
  _account_id UUID;
  _legal_term_id UUID;
  _verification UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
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
