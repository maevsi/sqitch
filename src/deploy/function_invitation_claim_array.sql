BEGIN;

CREATE FUNCTION maevsi.invitation_claim_array()
RETURNS UUID[] AS $$
DECLARE
  _invitation_ids UUID[];
  _invitation_ids_unblocked UUID[] := ARRAY[]::UUID[];
  _invitation_id UUID;
BEGIN
  _invitation_ids := string_to_array(replace(btrim(current_setting('jwt.claims.invitations', true), '[]'), '"', ''), ',')::UUID[];

  IF _invitation_ids IS NOT NULL THEN
    FOREACH _invitation_id IN ARRAY _invitation_ids
    LOOP
      -- omit invitations to events authored by an account blocked by the current user
      IF EXISTS (
	      SELECT 1
	      FROM maevsi.invitation i
	        JOIN maevsi.event e ON i.event_id = e.id
	      WHERE i.id = _invitation_id AND e.author_account_id NOT IN (
            SELECT id FROM maevsi_private.account_block_ids()
          )
	    ) THEN
        _invitation_ids_unblocked := array_append(_invitation_ids_unblocked, _invitation_id);
	    END IF;
    END LOOP;
  END IF;
  RETURN _invitation_ids_unblocked;
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY INVOKER;

COMMENT ON FUNCTION maevsi.invitation_claim_array() IS 'Returns the current invitation claims as UUID array.';

GRANT EXECUTE ON FUNCTION maevsi.invitation_claim_array() TO maevsi_account, maevsi_anonymous;

COMMIT;
