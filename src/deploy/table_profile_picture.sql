BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres_role_service_vibetype_username`

CREATE TABLE vibetype.profile_picture (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  account_id    UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,
  upload_id     UUID NOT NULL REFERENCES vibetype.upload(id) ON DELETE CASCADE,

  CONSTRAINT profile_picture_unique UNIQUE (account_id)
);

CREATE INDEX idx_profile_picture_upload_id ON vibetype.profile_picture USING btree (upload_id);

COMMENT ON TABLE vibetype.profile_picture IS 'Mapping of account ids to upload ids.';
COMMENT ON COLUMN vibetype.profile_picture.id IS E'@behavior -insert -update\nThe profile picture''s internal id.';
COMMENT ON COLUMN vibetype.profile_picture.account_id IS 'The account''s id.';
COMMENT ON COLUMN vibetype.profile_picture.upload_id IS 'The upload''s id.';

GRANT SELECT ON TABLE vibetype.profile_picture TO vibetype_anonymous;
GRANT INSERT, SELECT, DELETE, UPDATE ON TABLE vibetype.profile_picture TO vibetype_account;
GRANT SELECT, DELETE ON TABLE vibetype.profile_picture TO :role_service_vibetype_username;

ALTER TABLE vibetype.profile_picture ENABLE ROW LEVEL SECURITY;

CREATE POLICY profile_picture_all ON vibetype.profile_picture FOR ALL
USING (
  account_id = vibetype.invoker_account_id()
);

-- Make all profile pictures accessible by everyone.
CREATE POLICY profile_picture_select ON vibetype.profile_picture FOR SELECT USING (
  TRUE
);

-- Allow all profile pictures to be deleted by the service.
CREATE POLICY profile_picture_delete_service ON vibetype.profile_picture FOR DELETE
TO :role_service_vibetype_username
USING (
  TRUE
);

COMMIT;
