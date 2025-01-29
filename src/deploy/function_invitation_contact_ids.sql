BEGIN;

CREATE FUNCTION maevsi.invitation_contact_ids()
RETURNS TABLE (contact_id UUID) AS $$
BEGIN
  RETURN QUERY
    -- get all contacts for invitations
    SELECT invitation.contact_id
    FROM maevsi.invitation
    WHERE
      (
        -- that are known to the invoker
        invitation.id = ANY (maevsi.invitation_claim_array())
      OR
        -- or for events organized by the invoker
        invitation.event_id IN (SELECT maevsi.events_organized())
      )
      AND
        -- except contacts created by a blocked account or referring to a blocked account
        invitation.contact_id NOT IN (
          SELECT contact.id
          FROM maevsi.contact
          WHERE
              contact.account_id IS NULL -- TODO: evaluate if this null check is necessary
            OR
              contact.account_id IN (
                SELECT id FROM maevsi_private.account_block_ids()
              )
            OR
              contact.created_by IN (
                SELECT id FROM maevsi_private.account_block_ids()
              )
        );
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.invitation_contact_ids() IS 'Returns contact ids that are accessible through invitations.';

GRANT EXECUTE ON FUNCTION maevsi.invitation_contact_ids() TO maevsi_account, maevsi_anonymous;

COMMIT;
