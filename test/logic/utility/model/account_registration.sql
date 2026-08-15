CREATE OR REPLACE FUNCTION vibetype_test.email_address_verification_confirmed (
  _email_address TEXT,
  _language TEXT,
  _time_zone TEXT DEFAULT 'UTC'
) RETURNS UUID
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _code UUID;
BEGIN
  PERFORM vibetype.email_address_verification_request(_email_address, _language, _time_zone);

  SELECT eav.code INTO _code
    FROM vibetype_private.email_address_verification eav
    JOIN vibetype_private.email_address ea ON ea.id = eav.email_address_id
    WHERE ea.address = _email_address;

  RETURN vibetype.email_address_verification(_code);
END $$;

GRANT EXECUTE ON FUNCTION vibetype_test.email_address_verification_confirmed(TEXT, TEXT, TEXT) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.email_address_verification_pending (
  _email_address TEXT,
  _language TEXT,
  _time_zone TEXT DEFAULT 'UTC'
) RETURNS UUID
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _id UUID;
BEGIN
  PERFORM vibetype.email_address_verification_request(_email_address, _language, _time_zone);

  SELECT eav.id INTO _id
    FROM vibetype_private.email_address_verification eav
    JOIN vibetype_private.email_address ea ON ea.id = eav.email_address_id
    WHERE ea.address = _email_address;

  RETURN _id;
END $$;

GRANT EXECUTE ON FUNCTION vibetype_test.email_address_verification_pending(TEXT, TEXT, TEXT) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.email_address_verification_exists (
  _email_address TEXT
) RETURNS BOOLEAN
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM vibetype_private.email_address_verification eav
    JOIN vibetype_private.email_address ea ON ea.id = eav.email_address_id
    WHERE ea.address = _email_address
  );
$$;

GRANT EXECUTE ON FUNCTION vibetype_test.email_address_verification_exists(TEXT) TO vibetype_account;


CREATE FUNCTION vibetype_test.account_registration_verified (
  _username TEXT,
  _email_address TEXT
) RETURNS UUID
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _account_id UUID;
  _legal_term_id UUID;
  _verification_id UUID;
BEGIN
  _legal_term_id := vibetype_test.legal_term_select_by_singleton();
  _verification_id := vibetype_test.email_address_verification_confirmed(_email_address, 'en', 'UTC');

  PERFORM vibetype.account_registration(_verification_id, '1970-01-01', _legal_term_id, 'password', _username);

  SELECT id INTO _account_id
  FROM vibetype.account
  WHERE username = _username;

  RETURN _account_id;
END $$;

GRANT EXECUTE ON FUNCTION vibetype_test.account_registration_verified(TEXT, TEXT) TO vibetype_account;
