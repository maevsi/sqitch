BEGIN;

CREATE FUNCTION maevsi.account_upload_quota_bytes() RETURNS BIGINT AS $$
BEGIN
  RETURN (SELECT upload_quota_bytes FROM maevsi_private.account WHERE account.id = current_setting('jwt.claims.account_id')::UUID);
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.account_upload_quota_bytes() IS 'Gets the total upload quota in bytes for the invoking account.';

GRANT EXECUTE ON FUNCTION maevsi.account_upload_quota_bytes() TO maevsi_account;

COMMIT;
