BEGIN;

CREATE OR REPLACE FUNCTION vibetype.account_registration_refresh(account_id uuid, language text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
BEGIN
  RAISE 'Refreshing registrations is currently not available due to missing rate limiting!' USING ERRCODE = 'deprecated_feature';

  IF (NOT EXISTS (SELECT 1 FROM vibetype_private.account WHERE account.id = account_registration_refresh.account_id)) THEN
    RAISE 'An account with this account id does not exist!' USING ERRCODE = 'invalid_parameter_value';
  END IF;

  UPDATE vibetype_private.account
    SET email_address_verification = DEFAULT
    WHERE account.id = account_registration_refresh.account_id;

  PERFORM vibetype_private.outbox_insert(
    'account',
    account_registration_refresh.account_id,
    'account.registration_refreshed',
    jsonb_build_object('account_id', account_registration_refresh.account_id, 'language', account_registration_refresh.language)
  );
END;
$$;

COMMIT;
