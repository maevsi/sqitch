-- Deploy maevsi:function_account_registration_refresh to pg
-- requires: privilege_execute_revoke
-- requires: schema_public
-- requires: schema_private
-- requires: table_account_private
-- requires: table_notification
-- requires: role_anonymous

BEGIN;

CREATE FUNCTION maevsi.account_registration_refresh(
  account_id UUID,
  "language" TEXT
) RETURNS VOID AS $$
DECLARE
  _new_account_notify RECORD;
BEGIN
  RAISE 'Refreshing registrations is currently not available due to missing rate limiting!' USING ERRCODE = 'deprecated_feature';

  IF (NOT EXISTS (SELECT 1 FROM maevsi_private.account WHERE account.id = $1)) THEN
    RAISE 'An account with this account id does not exists!' USING ERRCODE = 'invalid_parameter_value';
  END IF;

  WITH updated AS (
    UPDATE maevsi_private.account
      SET email_address_verification = DEFAULT
      WHERE account.id = $1
      RETURNING *
  ) SELECT
    account.username,
    updated.email_address,
    updated.email_address_verification,
    updated.email_address_verification_valid_until
    FROM updated, maevsi.account
    WHERE updated.id = account.id
    INTO _new_account_notify;

  INSERT INTO maevsi_private.notification (channel, payload) VALUES (
    'account_registration',
    jsonb_pretty(jsonb_build_object(
      'account', row_to_json(_new_account_notify),
      'template', jsonb_build_object('language', $2)
    ))
  );
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.account_registration_refresh(UUID, TEXT) IS 'Refreshes an account''s email address verification validity period.';

GRANT EXECUTE ON FUNCTION maevsi.account_registration_refresh(UUID, TEXT) TO maevsi_anonymous;

COMMIT;
