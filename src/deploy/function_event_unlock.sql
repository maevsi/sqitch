BEGIN;

CREATE FUNCTION vibetype.event_unlock(guest_id uuid) RETURNS vibetype.event_unlock_response
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _session_id UUID;
  _session vibetype.session;
  _event vibetype.event;
  _event_creator_account_username TEXT;
  _event_id UUID;
BEGIN
  _session_id := current_setting('jwt.claims.id', true)::UUID;
  _session := (
    _session_id,
    vibetype.invoker_account_id(), -- prevent empty string cast to UUID
    current_setting('jwt.claims.account_username', true)::TEXT,
    current_setting('jwt.claims.exp', true)::BIGINT,
    (SELECT ARRAY(SELECT DISTINCT UNNEST(vibetype.guest_claim_array() || event_unlock.guest_id) ORDER BY 1)),
    current_setting('jwt.claims.role', true)::TEXT
  )::vibetype.session;

  UPDATE vibetype_private.session
  SET token = _session
  WHERE id = _session_id;

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

  RETURN (_event_creator_account_username, _event.slug, _session)::vibetype.event_unlock_response;
END $$;

COMMENT ON FUNCTION vibetype.event_unlock(UUID) IS 'Adds a guest claim to the current session.\n\nError codes:\n- **P0002** when no guest, no event, or no event creator username was found for this guest id.';

GRANT EXECUTE ON FUNCTION vibetype.event_unlock(UUID) TO vibetype_account, vibetype_anonymous;

COMMIT;
