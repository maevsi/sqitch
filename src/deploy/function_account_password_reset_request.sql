BEGIN;

CREATE FUNCTION vibetype.account_password_reset_request(
  email_address TEXT,
  language TEXT
) RETURNS VOID AS $$
DECLARE
  _account vibetype_private.account%ROWTYPE;
  _notify_data RECORD := NULL;
BEGIN

  UPDATE vibetype_private.account
    SET password_reset_verification = gen_random_uuid()
    WHERE account.email_address = account_password_reset_request.email_address
    RETURNING * INTO _account;

  IF _account IS NOT NULL THEN
    SELECT
      username,
      _account.email_address,
      _account.password_reset_verification,
      _account.password_reset_verification_valid_until
      INTO _notify_data
      FROM vibetype.account
      WHERE id = _account.id;
  END IF;

  IF (_notify_data IS NULL) THEN
    -- noop
  ELSE
    INSERT INTO vibetype.notification (channel, payload, created_by) VALUES (
      'account_password_reset_request',
      jsonb_pretty(jsonb_build_object(
        'account', _notify_data,
        'template', jsonb_build_object('language', account_password_reset_request.language)
      )),
      _account.id
    );
  END IF;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.account_password_reset_request(TEXT, TEXT) IS 'Sets a new password reset verification code for an account.';

GRANT EXECUTE ON FUNCTION vibetype.account_password_reset_request(TEXT, TEXT) TO vibetype_anonymous, vibetype_account;

COMMIT;
