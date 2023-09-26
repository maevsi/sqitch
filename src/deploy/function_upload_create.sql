-- Deploy maevsi:function_upload_create to pg
-- requires: privilege_execute_revoke
-- requires: schema_public
-- requires: schema_private
-- requires: role_account
-- requires: table_upload
-- requires: table_account_private

BEGIN;

CREATE FUNCTION maevsi.upload_create(
  size_byte BIGINT
) RETURNS maevsi.upload AS $$
DECLARE
    _upload maevsi.upload;
BEGIN
  IF (COALESCE((
    SELECT SUM(upload.size_byte)
    FROM maevsi.upload
    WHERE upload.account_id = current_setting('jwt.claims.account_id', true)::UUID
  ), 0) + $1 <= (
    SELECT upload_quota_bytes
    FROM maevsi_private.account
    WHERE account.id = current_setting('jwt.claims.account_id', true)::UUID
  )) THEN
    INSERT INTO maevsi.upload(account_id, size_byte)
    VALUES (current_setting('jwt.claims.account_id', true)::UUID, $1)
    RETURNING upload.id INTO _upload;

    RETURN _upload;
  ELSE
    RAISE 'Upload quota limit reached!' USING ERRCODE = 'disk_full';
  END IF;
END;
$$ LANGUAGE PLPGSQL STRICT VOLATILE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.upload_create(BIGINT) IS 'Creates an upload with the given size if quota is available.';

GRANT EXECUTE ON FUNCTION maevsi.upload_create(BIGINT) TO maevsi_account;

COMMIT;
