BEGIN;

CREATE FUNCTION maevsi_private.account_block_ids()
RETURNS TABLE (id UUID) AS $$
BEGIN
  RETURN QUERY
    -- users blocked by the current user
    SELECT blocked_account_id
    FROM maevsi.account_block
    WHERE created_by = maevsi.invoker_account_id()
    UNION ALL
    -- users who blocked the current user
    SELECT created_by
    FROM maevsi.account_block
    WHERE blocked_account_id = maevsi.invoker_account_id();
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi_private.account_block_ids() IS 'Returns all account ids being blocked by the invoker and all accounts that blocked the invoker.';

GRANT EXECUTE ON FUNCTION maevsi_private.account_block_ids() TO maevsi_account, maevsi_anonymous;

COMMIT;
