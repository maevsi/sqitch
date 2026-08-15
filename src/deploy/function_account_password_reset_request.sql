BEGIN;

CREATE FUNCTION vibetype.account_password_reset_request(email_address text, language text, time_zone text DEFAULT 'UTC') RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _account_id UUID;
  _subject_id UUID;
  _password_reset_verification UUID;
  _password_reset_verification_valid_until TIMESTAMP WITH TIME ZONE;
  _outbox_id UUID := public.gen_random_uuid();
BEGIN
  SELECT aea.account_id, ea.subject_id INTO _account_id, _subject_id
    FROM vibetype_private.email_address ea
    JOIN vibetype_private.account_email_address aea ON aea.email_address_id = ea.id
    WHERE ea.address = account_password_reset_request.email_address
      AND aea.is_primary
      AND aea.verification IS NULL;

  IF (_account_id IS NULL) THEN
    RETURN; -- silent no-op, matching the existing anti-enumeration pattern for unknown addresses
  END IF;

  UPDATE vibetype_private.account
    SET password_reset_verification = public.gen_random_uuid()
    WHERE id = _account_id
    RETURNING password_reset_verification, password_reset_verification_valid_until
    INTO _password_reset_verification, _password_reset_verification_valid_until;

  INSERT INTO vibetype_private.outbox (id, aggregate_type, aggregate_id, type, payload) VALUES (
    _outbox_id,
    'account',
    _account_id,
    'account.password_reset_requested',
    jsonb_build_object(
      'id', _outbox_id,
      'account_id', _account_id,
      'type', 'account.password_reset_requested',
      'password_reset_verification_valid_until', _password_reset_verification_valid_until,
      'encrypted', encode(vibetype_private.outbox_encrypt(_subject_id, jsonb_build_object(
        'emailAddress', account_password_reset_request.email_address,
        'passwordResetVerification', _password_reset_verification
      )), 'base64'),
      'template', jsonb_build_object('language', account_password_reset_request.language, 'time_zone', account_password_reset_request.time_zone)
    )
  );
END;
$$;

COMMENT ON FUNCTION vibetype.account_password_reset_request(TEXT, TEXT, TEXT) IS 'Sets a new password reset verification code for an account.';

GRANT EXECUTE ON FUNCTION vibetype.account_password_reset_request(TEXT, TEXT, TEXT) TO vibetype_anonymous, vibetype_account;

COMMIT;
