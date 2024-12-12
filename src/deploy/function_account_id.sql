BEGIN;

CREATE FUNCTION maevsi.account_id() RETURNS UUID AS $$
BEGIN
  RETURN NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER STABLE;

COMMENT ON FUNCTION maevsi.account_id() IS 'Returns the session''s account id.';

GRANT EXECUTE ON FUNCTION maevsi.account_id() TO maevsi_account, maevsi_anonymous;

COMMIT;
