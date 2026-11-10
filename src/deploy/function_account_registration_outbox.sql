BEGIN;

CREATE OR REPLACE FUNCTION vibetype.account_registration(birth_date date, email_address text, language text, legal_term_id uuid, password text, username text, time_zone text DEFAULT 'UTC') RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _new_account_private vibetype_private.account;
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
    (_new_account_private.id, account_registration.username);

  INSERT INTO vibetype.legal_term_acceptance(account_id, legal_term_id) VALUES
    (_new_account_private.id, account_registration.legal_term_id);

  INSERT INTO vibetype.contact(account_id, created_by) VALUES (_new_account_private.id, _new_account_private.id);

  PERFORM vibetype_private.outbox_insert(
    'account',
    _new_account_private.id,
    'account.registered',
    jsonb_build_object('account_id', _new_account_private.id, 'language', account_registration.language)
  );

  -- not possible to return data here as this would make the silent return above for email address duplicates distinguishable from a successful registration
END;
$$;

COMMIT;
