-- Deploy maevsi:function_invitation_contact_ids to pg
-- requires: privilege_execute_revoke
-- requires: schema_public
-- requires: table_invitation
-- requires: table_contact
-- requires: table_account_block
-- requires: function_invitation_claim_array
-- requires: function_events_organized
-- requires: role_account
-- requires: role_anonymous

BEGIN;

CREATE OR REPLACE FUNCTION maevsi.invitation_contact_ids()
RETURNS TABLE (contact_id UUID) AS $$
BEGIN
  RETURN QUERY
    SELECT invitation.contact_id FROM maevsi.invitation
    WHERE id = ANY (maevsi.invitation_claim_array())
    OR (
	   event_id IN (SELECT maevsi.events_organized())
	   AND
	   -- omit contacts authored by a blocked account or referring to a blocked account
	   contact_id NOT IN (
		 SELECT c.id
		 FROM maevsi.contact c
		   JOIN maevsi.account_block b ON c.author_account_id = b.blocked_account_id OR c.account_id = b.blocked_account_id
		 WHERE b.author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
	   )
	);
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.invitation_contact_ids() IS 'Returns contact ids that are accessible through invitations.';

GRANT EXECUTE ON FUNCTION maevsi.invitation_contact_ids() TO maevsi_account, maevsi_anonymous;

COMMIT;
