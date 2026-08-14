BEGIN;

CREATE FUNCTION vibetype.account_password_reset_request(email_address text, language text, time_zone text DEFAULT 'UTC') RETURNS void
    LANGUAGE sql STRICT SECURITY DEFINER
    AS $$
  WITH outbox_id AS (
    SELECT gen_random_uuid() AS id
  ), updated AS (
    UPDATE vibetype_private.account
    SET password_reset_verification = gen_random_uuid()
    WHERE email_address = account_password_reset_request.email_address
    RETURNING id, email_address, password_reset_verification, password_reset_verification_valid_until
  )
  INSERT INTO vibetype_private.outbox (id, aggregate_type, aggregate_id, type, payload)
  SELECT
    o.id,
    'account',
    u.id,
    'account.password_reset_requested',
    jsonb_build_object(
    'id', o.id,
    'type', 'account.password_reset_requested',
    'account', jsonb_build_object(
      'username', a.username,
      'email_address', u.email_address,
      'password_reset_verification', u.password_reset_verification,
      'password_reset_verification_valid_until', u.password_reset_verification_valid_until
    ),
    'template', jsonb_build_object('language', account_password_reset_request.language, 'time_zone', account_password_reset_request.time_zone)
    )
  FROM outbox_id o, updated u
  JOIN vibetype.account a ON a.id = u.id;
$$;

COMMENT ON FUNCTION vibetype.account_password_reset_request(TEXT, TEXT, TEXT) IS 'Sets a new password reset verification code for an account.';

GRANT EXECUTE ON FUNCTION vibetype.account_password_reset_request(TEXT, TEXT, TEXT) TO vibetype_anonymous, vibetype_account;

COMMIT;
