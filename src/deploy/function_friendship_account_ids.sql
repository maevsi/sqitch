BEGIN;

CREATE FUNCTION maevsi.friendship_account_ids()
RETURNS TABLE (id UUID) AS $$
BEGIN
  RETURN QUERY
    WITH friend_bidirectional_account_ids AS (
      SELECT b_account_id as account_id
      FROM maevsi.friendship
      WHERE a_account = maevsi.invoker_account_id()
        and status = 'accepted'::maevsi.friendship_status
      UNION ALL
      SELECT a_account_id as account_id
      FROM maevsi.friendship
      WHERE b_account_id = maevsi.invoker_account_id()
        and status = 'accepted'::maevsi.friendship_status
    )
    SELECT account_id
    FROM friend_bidirectional_account_ids
    WHERE account NOT IN (maevsi_private.account_block_ids());
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.friendship_account_ids() IS 'Returns the account ids of all the invoker''s friends.';

GRANT EXECUTE ON FUNCTION maevsi.friendship_account_ids() TO maevsi_account;

COMMIT;
