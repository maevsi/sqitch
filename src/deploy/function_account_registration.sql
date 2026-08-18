BEGIN;

CREATE FUNCTION vibetype.account_registration(email_address_verification_id uuid, birth_date date, legal_term_id uuid, password text, username text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _email_address_id UUID;
  _email_address TEXT;
  _language TEXT;
  _time_zone TEXT;
  _new_account_private vibetype_private.account;
  _outbox_id UUID := public.gen_random_uuid();
BEGIN
  SELECT ea.id, ea.address, eav.language, eav.time_zone
    INTO _email_address_id, _email_address, _language, _time_zone
    FROM vibetype_private.email_address_verification eav
    JOIN vibetype_private.email_address ea ON ea.id = eav.email_address_id
    WHERE eav.id = account_registration.email_address_verification_id
      AND eav.confirmed_at IS NOT NULL
      -- A confirmed verification can still be long abandoned; require it to also still be within
      -- its validity window, so a stale confirmed link can't complete registration indefinitely.
      AND CURRENT_TIMESTAMP <= eav.valid_until;

  IF (_email_address_id IS NULL) THEN
    RAISE 'Email address verification not found or not confirmed!' USING ERRCODE = 'no_data_found';
  END IF;

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

  IF (EXISTS (SELECT 1 FROM vibetype_private.account_email_address WHERE email_address_id = _email_address_id)) THEN
    RETURN; -- silent fail, e.g. if the same confirmed verification is somehow consumed twice
  END IF;

  INSERT INTO vibetype_private.account(birth_date, password_hash, last_activity) VALUES
    (account_registration.birth_date, public.crypt(account_registration.password, public.gen_salt('bf')), CURRENT_TIMESTAMP)
    RETURNING * INTO _new_account_private;

  INSERT INTO vibetype.account(id, username) VALUES
    (_new_account_private.id, account_registration.username);

  INSERT INTO vibetype_private.account_email_address (account_id, email_address_id, verification) VALUES
    (_new_account_private.id, _email_address_id, NULL);

  INSERT INTO vibetype.legal_term_acceptance(account_id, legal_term_id) VALUES
    (_new_account_private.id, account_registration.legal_term_id);

  INSERT INTO vibetype.contact(account_id, created_by) VALUES (_new_account_private.id, _new_account_private.id);

  DELETE FROM vibetype_private.email_address_verification WHERE id = account_registration.email_address_verification_id;

  INSERT INTO vibetype_private.outbox (id, aggregate_type, aggregate_id, type, payload) VALUES (
    _outbox_id,
    'account',
    _new_account_private.id,
    'account.registered',
    jsonb_build_object(
      'id', _outbox_id,
      'account_id', _new_account_private.id,
      'type', 'account.registered',
      'encrypted', encode(vibetype_private.outbox_encrypt(
        (SELECT subject_id FROM vibetype_private.email_address WHERE id = _email_address_id),
        jsonb_build_object('emailAddress', _email_address, 'username', account_registration.username)
      ), 'base64'),
      'template', jsonb_build_object('language', _language, 'time_zone', _time_zone)
    )
  );

  -- not possible to return data here as this would make the silent return above distinguishable from a successful registration
END;
$$;

COMMENT ON FUNCTION vibetype.account_registration(UUID, DATE, UUID, TEXT, TEXT) IS 'Completes registration for a confirmed email address verification: creates the account, contact, and legal term acceptance, and fires a welcome email.\n\nError codes:\n- **P0002** when the email address verification is not found or not confirmed.\n- **VTBDA** when the birth date is not at least 18 years old.\n- **VTPLL** when the password length does not reach its minimum.\n- **VTAUV** when an account with the given username already exists.';

GRANT EXECUTE ON FUNCTION vibetype.account_registration(UUID, DATE, UUID, TEXT, TEXT) TO vibetype_anonymous, vibetype_account;

COMMIT;
