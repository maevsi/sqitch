BEGIN;

CREATE FUNCTION maevsi.event_unlock(
  guest_id UUID
) RETURNS maevsi.event_unlock_response AS $$
DECLARE
  _jwt_id UUID;
  _jwt maevsi.jwt;
  _event maevsi.event;
  _event_creator_account_username TEXT;
  _event_id UUID;
BEGIN
  _jwt_id := current_setting('jwt.claims.id', true)::UUID;
  _jwt := (
    _jwt_id,
    maevsi.invoker_account_id(), -- prevent empty string cast to UUID
    current_setting('jwt.claims.account_username', true)::TEXT,
    current_setting('jwt.claims.exp', true)::BIGINT,
    (SELECT ARRAY(SELECT DISTINCT UNNEST(maevsi.guest_claim_array() || event_unlock.guest_id) ORDER BY 1)),
    current_setting('jwt.claims.role', true)::TEXT
  )::maevsi.jwt;

  UPDATE maevsi_private.jwt
  SET token = _jwt
  WHERE id = _jwt_id;

  _event_id := (
    SELECT event_id FROM maevsi.guest
    WHERE guest.id = event_unlock.guest_id
  );

  IF (_event_id IS NULL) THEN
    RAISE 'No guest for this guest id found!' USING ERRCODE = 'no_data_found';
  END IF;

  SELECT *
    FROM maevsi.event
    WHERE id = _event_id
    INTO _event;

  IF (_event IS NULL) THEN
    RAISE 'No event for this guest id found!' USING ERRCODE = 'no_data_found';
  END IF;

  _event_creator_account_username := (
    SELECT username
    FROM maevsi.account
    WHERE id = _event.created_by
  );

  IF (_event_creator_account_username IS NULL) THEN
    RAISE 'No event creator username for this guest id found!' USING ERRCODE = 'no_data_found';
  END IF;

  RETURN (_event_creator_account_username, _event.slug, _jwt)::maevsi.event_unlock_response;
END $$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.event_unlock(UUID) IS 'Adds a guest claim to the current session.';

GRANT EXECUTE ON FUNCTION maevsi.event_unlock(UUID) TO maevsi_account, maevsi_anonymous;

COMMIT;
