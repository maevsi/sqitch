-- Deploy maevsi:function_account_username_by_id to pg
-- requires: privilege_execute_revoke
-- requires: schema_public
-- requires: schema_private
-- requires: table_account
-- requires: role_account
-- requires: role_anonymous

BEGIN;

CREATE FUNCTION maevsi.account_username_by_id(
  id UUID
) RETURNS TEXT AS $$
BEGIN
  RETURN (SELECT username FROM maevsi_private.account WHERE account_id = $1);
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.account_username_by_id(UUID) IS 'Gets the username of an account with the given id.';

GRANT EXECUTE ON FUNCTION maevsi.account_username_by_id(UUID) TO maevsi_account, maevsi_anonymous;

COMMIT;
