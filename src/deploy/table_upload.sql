-- Deploy maevsi:table_event to pg
-- requires: schema_public
-- requires: table_account_public
-- requires: role_account
-- requires: role_anonymous
-- requires: role_tusd

BEGIN;

CREATE TABLE maevsi.upload (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id     UUID NOT NULL REFERENCES maevsi.account(id),
  size_byte      BIGINT NOT NULL CHECK (size_byte > 0),
  storage_key    TEXT UNIQUE
);

COMMENT ON TABLE maevsi.upload IS 'An upload.';
COMMENT ON COLUMN maevsi.upload.id IS E'@omit create,update\nThe upload''s internal id.';
COMMENT ON COLUMN maevsi.upload.account_id IS 'The uploader''s account id.';
COMMENT ON COLUMN maevsi.upload.size_byte IS 'The upload''s size in bytes.';
COMMENT ON COLUMN maevsi.upload.storage_key IS 'The upload''s storage key.';

GRANT SELECT ON TABLE maevsi.upload TO maevsi_account, maevsi_anonymous, maevsi_tusd;
GRANT UPDATE ON TABLE maevsi.upload TO maevsi_tusd;
GRANT DELETE ON TABLE maevsi.upload TO maevsi_tusd;

ALTER TABLE maevsi.upload ENABLE ROW LEVEL SECURITY;

-- Display
-- - all uploads for `tusd` or
-- - the uploads that are linked to the requesting account or
-- - the uploads which are used as profile picture.
CREATE POLICY upload_select_using ON maevsi.upload FOR SELECT USING (
    (SELECT current_user) = 'maevsi_tusd'
  OR
    account_id = current_setting('jwt.claims.account_id', true)::UUID
  OR
    id IN (SELECT upload_id FROM maevsi.profile_picture)
);

-- Only allow tusd to update rows.
CREATE POLICY upload_update_using ON maevsi.upload FOR UPDATE USING (
  (SELECT current_user) = 'maevsi_tusd'
);

-- Only allow tusd to delete rows.
CREATE POLICY upload_delete_using ON maevsi.upload FOR DELETE USING (
  (SELECT current_user) = 'maevsi_tusd'
);

COMMIT;
