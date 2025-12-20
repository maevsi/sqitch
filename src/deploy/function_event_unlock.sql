BEGIN;

CREATE FUNCTION vibetype.event_unlock(guest_id uuid) RETURNS TABLE(creator_username TEXT, event_slug TEXT, jwt vibetype.jwt)
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _jwt_id UUID;
  _jwt vibetype.jwt;
  _event vibetype.event;
  _event_creator_account_username TEXT;
  _event_id UUID;
BEGIN
  _jwt_id := current_setting('jwt.claims.jti', true)::UUID;
  _jwt := (
    COALESCE(
      string_to_array(
        replace(btrim(current_setting('jwt.claims.attendances', true), '[]'), '"', ''),
        ','
      )::UUID[],
      '{}'::UUID[]
    ),
    current_setting('jwt.claims.exp', true)::BIGINT,
    (SELECT ARRAY(SELECT DISTINCT UNNEST(vibetype.guest_claim_array() || event_unlock.guest_id) ORDER BY 1)),
    _jwt_id,
    current_setting('jwt.claims.role', true)::TEXT,
    vibetype.invoker_account_id(),
    current_setting('jwt.claims.username', true)::TEXT
  )::vibetype.jwt;

  UPDATE vibetype_private.jwt
  SET token = _jwt
  WHERE id = _jwt_id;

  _event_id := (
    SELECT event_id FROM vibetype.guest
    WHERE guest.id = event_unlock.guest_id
  );

  IF (_event_id IS NULL) THEN
    RAISE 'No guest for this guest id found!' USING ERRCODE = 'no_data_found';
  END IF;

  SELECT *
    INTO _event
    FROM vibetype.event
    WHERE id = _event_id;

  IF (_event IS NULL) THEN
    RAISE 'No event for this guest id found!' USING ERRCODE = 'no_data_found';
  END IF;

  _event_creator_account_username := (
    SELECT username
    FROM vibetype.account
    WHERE id = _event.created_by
  );

  IF (_event_creator_account_username IS NULL) THEN
    RAISE 'No event creator username for this guest id found!' USING ERRCODE = 'no_data_found';
  END IF;

  RETURN QUERY SELECT _event_creator_account_username, _event.slug, _jwt;
END $$;

COMMENT ON FUNCTION vibetype.event_unlock(UUID) IS 'Adds a guest claim to the current session.\n\nError codes:\n- **P0002** when no guest, no event, or no event creator username was found for this guest id.';

GRANT EXECUTE ON FUNCTION vibetype.event_unlock(UUID) TO vibetype_account, vibetype_anonymous;

COMMIT;
