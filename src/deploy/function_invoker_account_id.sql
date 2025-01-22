BEGIN;

CREATE FUNCTION maevsi.invoker_account_id() RETURNS UUID AS $$
BEGIN
  RETURN NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER STABLE;

COMMENT ON FUNCTION maevsi.invoker_account_id() IS 'Returns the session''s account id.';

GRANT EXECUTE ON FUNCTION maevsi.invoker_account_id() TO maevsi_account, maevsi_anonymous, maevsi_tusd;

COMMIT;
