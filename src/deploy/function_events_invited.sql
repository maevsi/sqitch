BEGIN;

CREATE FUNCTION maevsi_private.events_invited()
RETURNS TABLE (event_id UUID) AS $$
DECLARE
  jwt_account_id UUID;
BEGIN
  jwt_account_id := NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID;

  RETURN QUERY
  SELECT invitation.event_id FROM maevsi.invitation
  WHERE
      invitation.contact_id IN (
        SELECT id
        FROM maevsi.contact
        WHERE
          jwt_account_id IS NOT NULL
          AND
          contact.account_id = jwt_account_id
      ) -- The contact selection does not return rows where account_id "IS" null due to the equality comparison.
  OR  invitation.id = ANY (maevsi.invitation_claim_array());
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi_private.events_invited() IS 'Add a function that returns all event ids for which the invoker is invited.';

GRANT EXECUTE ON FUNCTION maevsi_private.events_invited() TO maevsi_account, maevsi_anonymous;

COMMIT;
