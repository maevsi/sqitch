BEGIN;

CREATE FUNCTION vibetype.upload_create(
  size_byte BIGINT
) RETURNS vibetype.upload AS $$
DECLARE
  _upload vibetype.upload;
BEGIN
  IF (COALESCE((
    SELECT SUM(upload.size_byte)
    FROM vibetype.upload
    WHERE upload.created_by = current_setting('jwt.claims.account_id')::UUID
  ), 0) + upload_create.size_byte <= (
    SELECT upload_quota_bytes
    FROM vibetype_private.account
    WHERE account.id = current_setting('jwt.claims.account_id')::UUID
  )) THEN
    INSERT INTO vibetype.upload(created_by, size_byte)
    VALUES (current_setting('jwt.claims.account_id')::UUID, upload_create.size_byte)
    RETURNING upload.id INTO _upload;

    RETURN _upload;
  ELSE
    RAISE 'Upload quota limit reached!' USING ERRCODE = 'disk_full';
  END IF;
END;
$$ LANGUAGE PLPGSQL STRICT VOLATILE SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.upload_create(BIGINT) IS 'Creates an upload with the given size if quota is available.';

GRANT EXECUTE ON FUNCTION vibetype.upload_create(BIGINT) TO vibetype_account;

COMMIT;
