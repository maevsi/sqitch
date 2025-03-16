BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres_role_service_vibetype_username`

CREATE TABLE vibetype.profile_picture (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  account_id    UUID NOT NULL REFERENCES vibetype.account(id) UNIQUE,
  upload_id     UUID NOT NULL REFERENCES vibetype.upload(id)
);

COMMENT ON TABLE vibetype.profile_picture IS 'Mapping of account ids to upload ids.';
COMMENT ON COLUMN vibetype.profile_picture.id IS E'@omit create,update\nThe profile picture''s internal id.';
COMMENT ON COLUMN vibetype.profile_picture.account_id IS 'The account''s id.';
COMMENT ON COLUMN vibetype.profile_picture.upload_id IS 'The upload''s id.';

GRANT SELECT ON TABLE vibetype.profile_picture TO vibetype_account, vibetype_anonymous, :role_service_vibetype_username;
GRANT INSERT, DELETE, UPDATE ON TABLE vibetype.profile_picture TO vibetype_account;
GRANT DELETE ON TABLE vibetype.profile_picture TO :role_service_vibetype_username;

ALTER TABLE vibetype.profile_picture ENABLE ROW LEVEL SECURITY;

-- Make all profile pictures accessible by everyone.
CREATE POLICY profile_picture_select ON vibetype.profile_picture FOR SELECT USING (
  TRUE
);

-- Only allow inserts with a account id that matches the invoker's account id.
CREATE POLICY profile_picture_insert ON vibetype.profile_picture FOR INSERT WITH CHECK (
  vibetype.invoker_account_id() IS NOT NULL
  AND
  account_id = vibetype.invoker_account_id()
);

-- Only allow updates to the item with the account id that matches the invoker's account id.
CREATE POLICY profile_picture_update ON vibetype.profile_picture FOR UPDATE USING (
  vibetype.invoker_account_id() IS NOT NULL
  AND
  account_id = vibetype.invoker_account_id()
);

-- Only allow deletes for the item with the account id that matches the invoker's account id.
CREATE POLICY profile_picture_delete ON vibetype.profile_picture FOR DELETE USING (
    (SELECT current_user) = :'role_service_vibetype_username'
  OR
    (
      vibetype.invoker_account_id() IS NOT NULL
      AND
      account_id = vibetype.invoker_account_id()
    )
);

COMMIT;
