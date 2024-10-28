-- Deploy maevsi:function_events_invited to pg
-- requires: privilege_execute_revoke
-- requires: schema_private
-- requires: schema_public
-- requires: table_invitation
-- requires: table_contact
-- requires: table_account_block
-- requires: role_account
-- requires: role_anonymous

BEGIN;

CREATE OR REPLACE FUNCTION maevsi_private.events_invited()
  RETURNS TABLE(event_id uuid)
AS $$
DECLARE
  jwt_account_id UUID;
BEGIN
  jwt_account_id := NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID;

  RETURN QUERY
  SELECT event_id FROM maevsi.invitation
  WHERE
    (
      contact_id IN (
        SELECT id
        FROM maevsi.contact
        WHERE
          account_id = jwt_account_id
		  -- The contact selection does not return rows where account_id "IS" null due to the equality comparison.
		  AND
		  -- contact not created by a blocked account
		  author_account_id NOT IN (
			SELECT account_block_id
			FROM maevsi.account_block
		    WHERE b.author_account_id = jwt_account_id
		  )
		)
    )
    OR id = ANY (maevsi.invitation_claim_array());
END
$$ LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
;

COMMENT ON FUNCTION maevsi_private.events_invited() IS 'Add a function that returns all event ids for which the invoker is invited.';

GRANT EXECUTE ON FUNCTION maevsi_private.events_invited() TO maevsi_account, maevsi_anonymous;

COMMIT;
