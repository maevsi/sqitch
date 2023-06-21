-- Deploy maevsi:function_event_unlock to pg
-- requires: privilege_execute_revoke
-- requires: schema_public
-- requires: table_invitation
-- requires: table_event
-- requires: type_event_unlock_response
-- requires: function_invitation_claims_to_array
-- requires: type_jwt
-- requires: table_jwt

BEGIN;

CREATE FUNCTION maevsi.event_unlock(
  invitation_id UUID
) RETURNS maevsi.event_unlock_response AS $$
DECLARE
  _jwt_id UUID;
  _jwt maevsi.jwt;
  _event maevsi.event;
  _event_author_account_username TEXT;
  _event_id UUID;
BEGIN
  _jwt_id := current_setting('jwt.claims.id', true)::UUID;
  _jwt := (
    _jwt_id,
    current_setting('jwt.claims.account_id', true)::UUID,
    current_setting('jwt.claims.account_username', true)::TEXT,
    current_setting('jwt.claims.exp', true)::BIGINT,
    (SELECT ARRAY(SELECT DISTINCT UNNEST(maevsi.invitation_claim_array() || $1) ORDER BY 1)),
    current_setting('jwt.claims.role', true)::TEXT
  )::maevsi.jwt;

  UPDATE maevsi_private.jwt
  SET token = _jwt
  WHERE id = _jwt_id;

  _event_id := (
    SELECT event_id FROM maevsi.invitation
    WHERE invitation.id = $1
  );

  IF (_event_id IS NULL) THEN
    RAISE 'No invitation for this invitation id found!' USING ERRCODE = 'no_data_found';
  END IF;

  _event := (
    SELECT author_account_id, slug
    FROM maevsi.event
    WHERE id = _event_id
  );

  IF (_event IS NULL) THEN
    RAISE 'No event for this invitation id found!' USING ERRCODE = 'no_data_found';
  END IF;

  _event_author_account_username := maevsi.account_username_by_id(_event.author_account_id);

  IF (_event_author_account_username IS NULL) THEN
    RAISE 'No event author username for this invitation id found!' USING ERRCODE = 'no_data_found';
  END IF;

  RETURN (_event_author_account_username, _event.slug, _jwt)::maevsi.event_unlock_response;
END $$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.event_unlock(UUID) IS 'Assigns an invitation to the current session.';

GRANT EXECUTE ON FUNCTION maevsi.event_unlock(UUID) TO maevsi_account, maevsi_anonymous;

COMMIT;
