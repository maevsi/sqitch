BEGIN;

CREATE FUNCTION vibetype.email_address_verification_request(email_address text, language text, time_zone text DEFAULT 'UTC') RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _email_address_id UUID;
  _subject_id UUID;
  _verification_code UUID;
  _verification_valid_until TIMESTAMP WITH TIME ZONE;
  _outbox_id UUID := public.gen_random_uuid();
BEGIN
  SELECT id, subject_id INTO _email_address_id, _subject_id
    FROM vibetype_private.email_address
    WHERE address = email_address_verification_request.email_address;

  IF _email_address_id IS NULL THEN
    INSERT INTO vibetype_private.subject DEFAULT VALUES RETURNING id INTO _subject_id;
    INSERT INTO vibetype_private.email_address (subject_id, address) VALUES (_subject_id, email_address_verification_request.email_address)
      RETURNING id INTO _email_address_id;
  ELSIF (EXISTS (SELECT 1 FROM vibetype_private.account_email_address aea WHERE aea.email_address_id = _email_address_id)) THEN
    RETURN; -- silent no-op, matching the existing anti-enumeration pattern for already-registered addresses
  END IF;

  -- only one pending verification per address; a repeated request invalidates any earlier code
  DELETE FROM vibetype_private.email_address_verification WHERE email_address_id = _email_address_id AND confirmed_at IS NULL;

  INSERT INTO vibetype_private.email_address_verification (email_address_id, language, time_zone) VALUES
    (_email_address_id, email_address_verification_request.language, email_address_verification_request.time_zone)
    RETURNING code, valid_until INTO _verification_code, _verification_valid_until;

  INSERT INTO vibetype_private.outbox (id, aggregate_type, aggregate_id, type, payload) VALUES (
    _outbox_id,
    'email_address',
    _email_address_id,
    'email_address_verification.requested',
    jsonb_build_object(
      'id', _outbox_id,
      'email_address_id', _email_address_id,
      'type', 'email_address_verification.requested',
      'valid_until', _verification_valid_until,
      'encrypted', encode(vibetype_private.outbox_encrypt(_subject_id, jsonb_build_object(
        'emailAddress', email_address_verification_request.email_address,
        'code', _verification_code
      )), 'base64'),
      'template', jsonb_build_object('language', email_address_verification_request.language, 'time_zone', email_address_verification_request.time_zone)
    )
  );
END;
$$;

COMMENT ON FUNCTION vibetype.email_address_verification_request(TEXT, TEXT, TEXT) IS 'Requests a proof-of-ownership confirmation email for an address, before any account exists. Calling it again for an address with a still-pending verification issues a fresh code and invalidates the previous one.';

GRANT EXECUTE ON FUNCTION vibetype.email_address_verification_request(TEXT, TEXT, TEXT) TO vibetype_anonymous, vibetype_account;

COMMIT;
