BEGIN;

CREATE FUNCTION vibetype.account_password_reset_request(
  email_address TEXT,
  language TEXT
) RETURNS VOID AS $$
DECLARE
  _notify_data RECORD;
BEGIN
  WITH updated AS (
    UPDATE vibetype_private.account
      SET password_reset_verification = gen_random_uuid()
      WHERE account.email_address = account_password_reset_request.email_address
      RETURNING *
  ) SELECT
    account.username,
    updated.email_address,
    updated.password_reset_verification,
    updated.password_reset_verification_valid_until
    FROM updated, vibetype.account
    WHERE updated.id = account.id
    INTO _notify_data;

  IF (_notify_data IS NULL) THEN
    -- noop
  ELSE
    INSERT INTO vibetype_private.notification (channel, payload) VALUES (
      'account_password_reset_request',
      jsonb_pretty(jsonb_build_object(
        'account', _notify_data,
        'template', jsonb_build_object('language', account_password_reset_request.language)
      ))
    );
  END IF;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.account_password_reset_request(TEXT, TEXT) IS 'Sets a new password reset verification code for an account.';

GRANT EXECUTE ON FUNCTION vibetype.account_password_reset_request(TEXT, TEXT) TO vibetype_anonymous, vibetype_account;

COMMIT;
