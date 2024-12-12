BEGIN;

CREATE FUNCTION maevsi.invitation_contact_ids()
RETURNS TABLE (contact_id UUID) AS $$
BEGIN
  RETURN QUERY
    SELECT invitation.contact_id FROM maevsi.invitation
    WHERE id = ANY (maevsi.invitation_claim_array())
    OR    event_id IN (SELECT maevsi.events_organized());
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.invitation_contact_ids() IS 'Returns contact ids that are accessible through invitations.';

GRANT EXECUTE ON FUNCTION maevsi.invitation_contact_ids() TO maevsi_account, maevsi_anonymous;

COMMIT;
