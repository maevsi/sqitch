BEGIN;

CREATE FUNCTION vibetype.email_address_verification(code uuid) RETURNS UUID
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _id UUID;
BEGIN
  UPDATE vibetype_private.email_address_verification eav
    SET confirmed_at = CURRENT_TIMESTAMP
    WHERE eav.code = email_address_verification.code
      AND eav.valid_until > CURRENT_TIMESTAMP
    RETURNING eav.id INTO _id;

  IF _id IS NULL THEN
    RAISE 'Verification code not found or expired!' USING ERRCODE = 'no_data_found';
  END IF;

  RETURN _id;
END;
$$;

COMMENT ON FUNCTION vibetype.email_address_verification(UUID) IS 'Confirms a pending email address verification code. Returns the verification''s own id for the caller to carry forward into whichever flow consumes it (e.g. account registration).\n\nError codes:\n- **P0002** when the code is unknown or expired.';

GRANT EXECUTE ON FUNCTION vibetype.email_address_verification(UUID) TO vibetype_anonymous, vibetype_account;

COMMIT;
