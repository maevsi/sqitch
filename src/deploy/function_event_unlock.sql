BEGIN;

CREATE FUNCTION vibetype.event_unlock(
  guest_id UUID
) RETURNS vibetype.event_unlock_response AS $$
DECLARE
  _jwt_id UUID;
  _jwt vibetype.jwt;
  _event vibetype.event;
  _event_creator_account_username TEXT;
  _event_id UUID;
BEGIN
  _jwt_id := current_setting('jwt.claims.id', true)::UUID;
  _jwt := (
    _jwt_id,
    vibetype.invoker_account_id(), -- prevent empty string cast to UUID
    current_setting('jwt.claims.account_username', true)::TEXT,
    current_setting('jwt.claims.exp', true)::BIGINT,
    (SELECT ARRAY(SELECT DISTINCT UNNEST(vibetype.guest_claim_array() || $1) ORDER BY 1)),
    current_setting('jwt.claims.role', true)::TEXT
  )::vibetype.jwt;

  UPDATE vibetype_private.jwt
  SET token = _jwt
  WHERE id = _jwt_id;

  _event_id := (
    SELECT event_id FROM vibetype.guest
    WHERE guest.id = $1
  );

  IF (_event_id IS NULL) THEN
    RAISE 'No guest for this guest id found!' USING ERRCODE = 'no_data_found';
  END IF;

  SELECT *
    FROM vibetype.event
    WHERE id = _event_id
    INTO _event;

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

  RETURN (_event_creator_account_username, _event.slug, _jwt)::vibetype.event_unlock_response;
END $$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.event_unlock(UUID) IS 'Adds a guest claim to the current session.';

GRANT EXECUTE ON FUNCTION vibetype.event_unlock(UUID) TO vibetype_account, vibetype_anonymous;

COMMIT;
