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
      -- omit invitations authored by a blocked account
      IF NOT EXISTS(
	      SELECT 1
	      FROM maevsi.invitation i
	      JOIN maevsi.contact c ON i.contact_id = c.contact_id
	      JOIN maevsi.account_block b ON c.author_account_id = b.blocked_account_id
	     WHERE i.id = _invitation_id and b.author_account_id = current_setting('jwt.claims.account_id', true)
	    ) THEN
        _invitation_ids_unblocked := append_invitation_array(result_invitation_ids, _invitation_id);
	    END IF;
    END LOOP;
  END IF;
  RETURN _invitation_ids_unblocked;
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY INVOKER
;

COMMENT ON FUNCTION maevsi.invitation_claim_array() IS 'Returns the current invitation claims as UUID array.';

GRANT EXECUTE ON FUNCTION maevsi.invitation_claim_array() TO maevsi_account, maevsi_anonymous;

COMMIT;
