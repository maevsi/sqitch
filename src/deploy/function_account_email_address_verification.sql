BEGIN;

CREATE FUNCTION vibetype.account_email_address_verification(
  code UUID
) RETURNS VOID AS $$
DECLARE
  _account vibetype_private.account;
BEGIN
  SELECT *
    FROM vibetype_private.account
    INTO _account
    WHERE account.email_address_verification = account_email_address_verification.code;

  IF (_account IS NULL) THEN
    RAISE 'Unknown verification code!' USING ERRCODE = 'no_data_found';
  END IF;

  IF (_account.email_address_verification_valid_until < CURRENT_TIMESTAMP) THEN
    RAISE 'Verification code expired!' USING ERRCODE = 'object_not_in_prerequisite_state';
  END IF;

  UPDATE vibetype_private.account
    SET email_address_verification = NULL
    WHERE email_address_verification = account_email_address_verification.code;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.account_email_address_verification(UUID) IS 'Sets the account''s email address verification code to `NULL` for which the email address verification code equals the one passed and is up to date.';

GRANT EXECUTE ON FUNCTION vibetype.account_email_address_verification(UUID) TO vibetype_account, vibetype_anonymous;


CREATE FUNCTION vibetype_test.account_registration_verified (
  _username TEXT,
  _email_address TEXT
) RETURNS UUID AS $$
DECLARE
  _id UUID;
  _verification UUID;
BEGIN
  _id := vibetype.account_registration(_username, _email_address, 'password', 'en');

  SELECT email_address_verification INTO _verification
  FROM vibetype_private.account
  WHERE id = _id;

  PERFORM vibetype.account_email_address_verification(_verification);

  RETURN _id;
END $$ LANGUAGE plpgsql;

COMMIT;
