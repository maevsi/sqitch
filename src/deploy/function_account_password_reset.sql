BEGIN;

CREATE FUNCTION vibetype.account_password_reset(
  code UUID,
  password TEXT
) RETURNS VOID AS $$
DECLARE
  _account vibetype_private.account;
BEGIN
  IF (char_length(account_password_reset.password) < 8) THEN
    RAISE 'Password too short!' USING ERRCODE = 'invalid_parameter_value';
  END IF;

  SELECT *
    FROM vibetype_private.account
    INTO _account
    WHERE account.password_reset_verification = account_password_reset.code;

  IF (_account IS NULL) THEN
    RAISE 'Unknown reset code!' USING ERRCODE = 'no_data_found';
  END IF;

  IF (_account.password_reset_verification_valid_until < CURRENT_TIMESTAMP) THEN
    RAISE 'Reset code expired!' USING ERRCODE = 'object_not_in_prerequisite_state';
  END IF;

  UPDATE vibetype_private.account
    SET
      password_hash = crypt(account_password_reset.password, gen_salt('bf')),
      password_reset_verification = NULL
    WHERE account.password_reset_verification = account_password_reset.code;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.account_password_reset(UUID, TEXT) IS 'Sets a new password for an account if there was a request to do so before that''s still up to date.';

GRANT EXECUTE ON FUNCTION vibetype.account_password_reset(UUID, TEXT) TO vibetype_anonymous, vibetype_account;

COMMIT;
