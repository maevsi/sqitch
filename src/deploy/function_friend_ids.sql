BEGIN;

CREATE OR REPLACE FUNCTION maevsi.friend_ids()
RETURNS TABLE (id UUID) AS $$
BEGIN
  RETURN QUERY
    WITH t AS (
      SELECT b_account_id as account_id
      FROM maevsi.friend
      WHERE a_account = maevsi.invoker_account_id()
        and status = 'accepted'::maevsi.friend_status
      UNION ALL
      SELECT a_account_id as account_id
      FROM maevsi.friend
      WHERE b_account_id = maevsi.invoker_account_id()
        and status = 'accepted'::maevsi.friend_status
    )
    SELECT account_id
    FROM t
    WHERE t.account NOT IN (maevsi_private.account_block_ids());
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.friend_ids() IS 'Returns the account ids of all the invoker''s friends.';

GRANT EXECUTE ON FUNCTION maevsi.friend_ids() TO maevsi_account;

COMMIT;
