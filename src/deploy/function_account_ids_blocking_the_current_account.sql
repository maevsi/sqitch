BEGIN;

CREATE FUNCTION vibetype_private.account_ids_blocking_the_current_account()
RETURNS TABLE (id UUID) AS $$
BEGIN
  RETURN QUERY
    SELECT created_by
    FROM vibetype.account_block
    WHERE blocked_account_id = vibetype.invoker_account_id();
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.account_ids_blocking_the_current_account() IS 'Returns all ids of accounts blocking the invoker account.';

GRANT EXECUTE ON FUNCTION vibetype_private.account_ids_blocking_the_current_account() TO vibetype_account, vibetype_anonymous;

COMMIT;
