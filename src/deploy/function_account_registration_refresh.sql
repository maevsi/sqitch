BEGIN;

CREATE FUNCTION vibetype.account_registration_refresh(
  account_id UUID,
  language TEXT
) RETURNS VOID AS $$
DECLARE
  _new_account_notify RECORD;
BEGIN
  RAISE 'Refreshing registrations is currently not available due to missing rate limiting!' USING ERRCODE = 'deprecated_feature';

  IF (NOT EXISTS (SELECT 1 FROM vibetype_private.account WHERE account.id = account_registration_refresh.account_id)) THEN
    RAISE 'An account with this account id does not exists!' USING ERRCODE = 'invalid_parameter_value';
  END IF;

  WITH updated AS (
    UPDATE vibetype_private.account
      SET email_address_verification = DEFAULT
      WHERE account.id = account_registration_refresh.account_id
      RETURNING *
  ) SELECT
    account.username,
    updated.email_address,
    updated.email_address_verification,
    updated.email_address_verification_valid_until
    FROM updated JOIN vibetype.account ON updated.id = account.id
    INTO _new_account_notify;

  INSERT INTO vibetype.notification (channel, payload) VALUES (
    'account_registration',
    jsonb_pretty(jsonb_build_object(
      'account', row_to_json(_new_account_notify),
      'template', jsonb_build_object('language', account_registration_refresh.language)
    ))
  );
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.account_registration_refresh(UUID, TEXT) IS 'Refreshes an account''s email address verification validity period.';

GRANT EXECUTE ON FUNCTION vibetype.account_registration_refresh(UUID, TEXT) TO vibetype_anonymous;

COMMIT;
