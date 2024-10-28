-- Deploy maevsi:function_invitation_claim_array to pg
-- requires: privilege_execute_revoke
-- requires: schema_public
-- requires: table_invitation
-- requires: table_contact
-- requires: table_account_block
-- requires: role_account
-- requires: role_anonymous

BEGIN;

CREATE OR REPLACE FUNCTION maevsi.invitation_claim_array()
RETURNS UUID[] AS $$
DECLARE
  _arr UUID[];
  _result_arr UUID[] := ARRAY[]::UUID[];
  _id UUID;
BEGIN
  _arr := string_to_array(replace(btrim(current_setting('jwt.claims.invitations', true), '[]'), '"', ''), ',')::UUID[];
  FOREACH _id IN ARRAY arr
  LOOP
    -- omit invitations authored by a blocked account
   IF NOT EXISTS(
	  SELECT 1
	  FROM maevsi.invitation i
	    JOIN maevsi.contact c ON i.contact_id = c.contact_id
	    JOIN maevsi.account_block b ON c.author_account_id = b.blocked_account_id
	  WHERE i.id = _id and b.author_account_id = current_setting('jwt.claims.account_id', true)
	) THEN
      _result_arr := append_array(result_arr, _id);
	END IF;
  END LOOP;

  RETURN _result_arr;
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY INVOKER;

GRANT EXECUTE ON FUNCTION maevsi.invitation_claim_array() TO maevsi_account, maevsi_anonymous;

COMMIT;
