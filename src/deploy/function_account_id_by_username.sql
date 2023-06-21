-- Deploy maevsi:function_account_id_by_username to pg
-- requires: privilege_execute_revoke
-- requires: schema_public
-- requires: schema_private
-- requires: table_account
-- requires: role_account
-- requires: role_anonymous

BEGIN;

CREATE FUNCTION maevsi.account_id_by_username(
  username TEXT
) RETURNS UUID AS $$
BEGIN
  RETURN (SELECT id FROM maevsi_private.account WHERE username = $1);
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.account_id_by_username(TEXT) IS 'Gets the id of an account with the given username.';

GRANT EXECUTE ON FUNCTION maevsi.account_id_by_username(TEXT) TO maevsi_account, maevsi_anonymous;

COMMIT;
