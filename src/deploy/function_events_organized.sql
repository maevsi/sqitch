-- Deploy maevsi:function_events_organized to pg
-- requires: privilege_execute_revoke
-- requires: schema_public
-- requires: table_event
-- requires: role_account
-- requires: role_anonymous

BEGIN;

CREATE FUNCTION maevsi.events_organized()
RETURNS TABLE (event_id UUID) AS $$
DECLARE
  account_id UUID;
BEGIN
  account_id := NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID;

  RETURN QUERY
    SELECT id FROM maevsi.event
    WHERE
      account_id IS NOT NULL
      AND
      "event".author_account_id = account_id;
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.events_organized() IS 'Add a function that returns all event ids for which the invoker is the author.';

GRANT EXECUTE ON FUNCTION maevsi.events_organized() TO maevsi_account, maevsi_anonymous;

COMMIT;
