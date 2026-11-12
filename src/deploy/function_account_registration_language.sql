BEGIN;

-- The language of the notification template also becomes the preferred
-- language of the account's own contact, as the app opens in that language;
-- unsupported values are left as NULL instead of failing the registration.
CREATE OR REPLACE FUNCTION vibetype.account_registration(birth_date date, email_address text, language text, legal_term_id uuid, password text, username text, time_zone text DEFAULT 'UTC') RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _new_account_private vibetype_private.account;
  _new_account_public vibetype.account;
  _new_account_notify RECORD;
BEGIN
  IF account_registration.birth_date > CURRENT_DATE - INTERVAL '18 years' THEN
    RAISE EXCEPTION 'The birth date must be at least 18 years in the past'
      USING ERRCODE = 'VTBDA';
  END IF;

  IF (char_length(account_registration.password) < 8) THEN
    RAISE 'Password too short!' USING ERRCODE = 'VTPLL';
  END IF;

  IF (EXISTS (SELECT 1 FROM vibetype.account WHERE account.username = account_registration.username)) THEN
    RAISE 'An account with this username already exists!' USING ERRCODE = 'VTAUV';
  END IF;

  IF (EXISTS (SELECT 1 FROM vibetype_private.account WHERE account.email_address = account_registration.email_address)) THEN
    RETURN; -- silent fail as we cannot return meta information about users' email addresses
  END IF;

  INSERT INTO vibetype_private.account(birth_date, email_address, password_hash, last_activity) VALUES
    (account_registration.birth_date, account_registration.email_address, public.crypt(account_registration.password, public.gen_salt('bf')), CURRENT_TIMESTAMP)
    RETURNING * INTO _new_account_private;

  INSERT INTO vibetype.account(id, username) VALUES
    (_new_account_private.id, account_registration.username)
    RETURNING * INTO _new_account_public;

  SELECT
    _new_account_public.username,
    _new_account_private.email_address,
    _new_account_private.email_address_verification,
    _new_account_private.email_address_verification_valid_until
  INTO _new_account_notify;

  INSERT INTO vibetype.legal_term_acceptance(account_id, legal_term_id) VALUES
    (_new_account_private.id, account_registration.legal_term_id);

  INSERT INTO vibetype.contact(account_id, created_by, language) VALUES
    (_new_account_private.id, _new_account_private.id, CASE WHEN account_registration.language IN ('de', 'en') THEN account_registration.language::vibetype.language END);

  INSERT INTO vibetype_private.notification (channel, payload) VALUES (
    'account_registration',
    jsonb_pretty(jsonb_build_object(
      'account', row_to_json(_new_account_notify),
      'template', jsonb_build_object('language', account_registration.language, 'time_zone', account_registration.time_zone)
    ))
  );

  -- not possible to return data here as this would make the silent return above for email address duplicates distinguishable from a successful registration
END;
$$;

COMMIT;
