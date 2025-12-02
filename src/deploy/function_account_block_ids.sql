BEGIN;

CREATE FUNCTION vibetype_private.account_block_ids() RETURNS TABLE(id uuid)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  -- users blocked by the current user
  SELECT blocked_account_id
  FROM vibetype.account_block
  WHERE created_by = vibetype.invoker_account_id()
  UNION ALL
  -- users who blocked the current user
  SELECT created_by
  FROM vibetype.account_block
  WHERE blocked_account_id = vibetype.invoker_account_id();
$$;

COMMENT ON FUNCTION vibetype_private.account_block_ids() IS 'Returns all account ids being blocked by the invoker and all accounts that blocked the invoker.';

GRANT EXECUTE ON FUNCTION vibetype_private.account_block_ids() TO vibetype_account, vibetype_anonymous;

COMMIT;
