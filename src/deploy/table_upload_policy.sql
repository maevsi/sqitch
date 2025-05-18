BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres_role_service_vibetype_username`

GRANT SELECT ON TABLE vibetype.upload TO vibetype_anonymous;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE vibetype.upload TO vibetype_account;
GRANT SELECT, UPDATE ON TABLE vibetype.upload TO :role_service_vibetype_username;

ALTER TABLE vibetype.upload ENABLE ROW LEVEL SECURITY;

-- Allow the service role to select and update rows.
CREATE POLICY upload_service_vibetype_all ON vibetype.upload FOR ALL
TO :role_service_vibetype_username
USING (
  TRUE
);

-- Allow accounts to create uploads for their own, but limit the upload quota per account.
CREATE POLICY upload_insert ON vibetype.upload FOR INSERT
WITH CHECK (
  created_by = vibetype.invoker_account_id()
);

CREATE FUNCTION vibetype.trigger_upload_insert()
RETURNS trigger AS $$
DECLARE
  _current_usage BIGINT;
  _quota BIGINT;
BEGIN
  SELECT COALESCE(SUM(size_byte), 0)
    INTO _current_usage
    FROM vibetype.upload
    WHERE created_by = NEW.created_by;

  SELECT upload_quota_bytes
    INTO _quota
    FROM vibetype_private.account
    WHERE id = NEW.created_by;

  IF (_current_usage + NEW.size_byte) > _quota THEN
    RAISE 'Upload quota limit reached!' USING ERRCODE = 'disk_full';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER vibetype_trigger_upload_insert
  BEFORE INSERT ON vibetype.upload
  FOR EACH ROW EXECUTE FUNCTION vibetype.trigger_upload_insert();

-- Display
-- - the uploads that were created by the requesting account or
-- - the uploads which are used as profile picture.
CREATE POLICY upload_select ON vibetype.upload FOR SELECT
USING (
    created_by = vibetype.invoker_account_id()
  OR
    id IN (SELECT upload_id FROM vibetype.profile_picture)
);

-- Allow accounts to update their own uploads.
CREATE POLICY upload_update ON vibetype.upload FOR UPDATE
USING (
  created_by = vibetype.invoker_account_id()
);

-- Allow accounts to delete their own uploads.
CREATE POLICY upload_delete ON vibetype.upload FOR DELETE
USING (
  created_by = vibetype.invoker_account_id()
);

COMMIT;
