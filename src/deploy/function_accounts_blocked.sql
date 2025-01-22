BEGIN;

CREATE FUNCTION maevsi.accounts_blocked()
RETURNS TABLE (id UUID) AS $$
BEGIN
  RETURN QUERY
    SELECT blocked_account_id
    FROM maevsi.account_block
    WHERE author_account_id = maevsi.invoker_account_id()
    UNION ALL
    SELECT author_account_id
    FROM maevsi.account_block
    WHERE blocked_account_id = maevsi.invoker_account_id();
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.accounts_blocked() IS 'Returns all account ids being blocked by the invoker and all accounts that blocked the invoker.';

GRANT EXECUTE ON FUNCTION maevsi.accounts_blocked() TO maevsi_account, maevsi_anonymous;

COMMIT;
