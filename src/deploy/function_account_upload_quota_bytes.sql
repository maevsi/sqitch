BEGIN;

CREATE FUNCTION vibetype.account_upload_quota_bytes() RETURNS BIGINT AS $$
BEGIN
  RETURN (SELECT upload_quota_bytes FROM vibetype_private.account WHERE account.id = current_setting('jwt.claims.account_id')::UUID);
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.account_upload_quota_bytes() IS 'Gets the total upload quota in bytes for the invoking account.';

GRANT EXECUTE ON FUNCTION vibetype.account_upload_quota_bytes() TO vibetype_account;

COMMIT;
