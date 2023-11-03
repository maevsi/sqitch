-- Deploy maevsi:table_profile_picture to pg
-- requires: schema_public
-- requires: table_account_public
-- requires: table_upload
-- requires: role_account
-- requires: role_anonymous
-- requires: role_tusd

BEGIN;

CREATE TABLE maevsi.profile_picture (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id    UUID NOT NULL REFERENCES maevsi.account(id) UNIQUE,
  upload_id     UUID NOT NULL REFERENCES maevsi.upload(id)
);

COMMENT ON TABLE maevsi.profile_picture IS 'Mapping of account ids to upload ids.';
COMMENT ON COLUMN maevsi.profile_picture.id IS E'@omit create,update\nThe profile picture''s internal id.';
COMMENT ON COLUMN maevsi.profile_picture.account_id IS 'The account''s id.';
COMMENT ON COLUMN maevsi.profile_picture.upload_id IS 'The upload''s id.';

GRANT SELECT ON TABLE maevsi.profile_picture TO maevsi_account, maevsi_anonymous, maevsi_tusd;
GRANT INSERT, DELETE, UPDATE ON TABLE maevsi.profile_picture TO maevsi_account;
GRANT DELETE ON TABLE maevsi.profile_picture TO maevsi_tusd;

ALTER TABLE maevsi.profile_picture ENABLE ROW LEVEL SECURITY;

-- Make all profile pictures accessible by everyone.
CREATE POLICY profile_picture_select ON maevsi.profile_picture FOR SELECT USING (
  TRUE
);

-- Only allow inserts with a account id that matches the invoker's account id.
CREATE POLICY profile_picture_insert ON maevsi.profile_picture FOR INSERT WITH CHECK (
  NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NOT NULL
  AND
  account_id = current_setting('jwt.claims.account_id', true)::UUID
);

-- Only allow updates to the item with the account id that matches the invoker's account id.
CREATE POLICY profile_picture_update ON maevsi.profile_picture FOR UPDATE USING (
  NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NOT NULL
  AND
  account_id = current_setting('jwt.claims.account_id', true)::UUID
);

-- Only allow deletes for the item with the account id that matches the invoker's account id.
CREATE POLICY profile_picture_delete ON maevsi.profile_picture FOR DELETE USING (
    (SELECT current_user) = 'maevsi_tusd'
  OR
    (
      NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NOT NULL
      AND
      account_id = current_setting('jwt.claims.account_id', true)::UUID
    )
);

COMMIT;
