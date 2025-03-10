BEGIN;

\set role_vibetype_username `cat /run/secrets/postgres_role_vibetype_username`

GRANT SELECT ON TABLE vibetype.upload TO vibetype_account, vibetype_anonymous, :role_vibetype_username;
GRANT UPDATE ON TABLE vibetype.upload TO :role_vibetype_username;
GRANT DELETE ON TABLE vibetype.upload TO :role_vibetype_username;

ALTER TABLE vibetype.upload ENABLE ROW LEVEL SECURITY;

-- Display
-- - all uploads for `vibetype` or -- DOTO: check why needed
-- - the uploads that are linked to the requesting account or
-- - the uploads which are used as profile picture.
CREATE POLICY upload_select_using ON vibetype.upload FOR SELECT USING (
    (SELECT current_user) = :'role_vibetype_username'
  OR
    (
      vibetype.invoker_account_id() IS NOT NULL
      AND
      account_id = vibetype.invoker_account_id()
    )
  OR
    id IN (SELECT upload_id FROM vibetype.profile_picture)
);

-- Only allow `vibetype` to update rows.
CREATE POLICY upload_update_using ON vibetype.upload FOR UPDATE USING (
  (SELECT current_user) = :'role_vibetype_username'
);

-- Only allow `vibetype` to delete rows.
CREATE POLICY upload_delete_using ON vibetype.upload FOR DELETE USING (
  (SELECT current_user) = :'role_vibetype_username'
);

COMMIT;
