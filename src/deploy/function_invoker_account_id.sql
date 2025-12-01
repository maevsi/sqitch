BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres_role_service_vibetype_username`

CREATE FUNCTION vibetype.invoker_account_id() RETURNS UUID AS $$
  SELECT NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID;
$$ LANGUAGE sql STRICT SECURITY DEFINER STABLE;

COMMENT ON FUNCTION vibetype.invoker_account_id() IS 'Returns the session''s account id.';

GRANT EXECUTE ON FUNCTION vibetype.invoker_account_id() TO vibetype_account, vibetype_anonymous, :role_service_vibetype_username;

COMMIT;
