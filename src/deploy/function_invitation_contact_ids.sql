BEGIN;

CREATE FUNCTION maevsi.invitation_contact_ids()
RETURNS TABLE (contact_id UUID) AS $$
BEGIN
  RETURN QUERY
    SELECT i.contact_id FROM maevsi.invitation i
    WHERE i.id = ANY (maevsi.invitation_claim_array())
    OR (
	    i.event_id IN (SELECT maevsi.events_organized())
	    AND
	    -- omit contacts authored by a blocked account or referring to a blocked account
	    i.contact_id NOT IN (
        SELECT c.id
        FROM maevsi.contact c
        WHERE c.account_id IS NULL
        OR c.account_id IN (
          SELECT blocked_account_id
          FROM maevsi.account_block
          WHERE author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
          UNION ALL
          SELECT author_account_id
          FROM maevsi.account_block
          WHERE blocked_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
        )
        OR c.author_account_id IN (
          SELECT blocked_account_id
          FROM maevsi.account_block
          WHERE author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
          UNION ALL
          SELECT author_account_id
          FROM maevsi.account_block
          WHERE blocked_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
        )
	   )
	);
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.invitation_contact_ids() IS 'Returns contact ids that are accessible through invitations.';

GRANT EXECUTE ON FUNCTION maevsi.invitation_contact_ids() TO maevsi_account, maevsi_anonymous;

COMMIT;
