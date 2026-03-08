BEGIN;

CREATE FUNCTION vibetype_private.account_block_ids() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT COALESCE(array_agg(blocked_id), ARRAY[]::UUID[])
  FROM (
    -- users blocked by the current user
    SELECT blocked_account_id AS blocked_id
    FROM vibetype.account_block
    WHERE created_by = vibetype.invoker_account_id()
    UNION ALL
    -- users who blocked the current user
    SELECT created_by AS blocked_id
    FROM vibetype.account_block
    WHERE blocked_account_id = vibetype.invoker_account_id()
  ) sub;
$$;

COMMENT ON FUNCTION vibetype_private.account_block_ids() IS 'Returns all account ids being blocked by the invoker and all accounts that blocked the invoker.';

GRANT EXECUTE ON FUNCTION vibetype_private.account_block_ids() TO vibetype_account, vibetype_anonymous;

COMMIT;
