BEGIN;

\set role_maevsi_tusd_username `cat /run/secrets/postgres_role_maevsi-tusd_username`

GRANT SELECT ON TABLE maevsi.upload TO maevsi_account, maevsi_anonymous, :role_maevsi_tusd_username;
GRANT UPDATE ON TABLE maevsi.upload TO :role_maevsi_tusd_username;
GRANT DELETE ON TABLE maevsi.upload TO :role_maevsi_tusd_username;

ALTER TABLE maevsi.upload ENABLE ROW LEVEL SECURITY;

-- Display
-- - all uploads for `tusd` or
-- - the uploads that are linked to the requesting account or
-- - the uploads which are used as profile picture.
CREATE POLICY upload_select_using ON maevsi.upload FOR SELECT USING (
    (SELECT current_user) = :'role_maevsi_tusd_username'
  OR
    (
      maevsi.invoker_account_id() IS NOT NULL
      AND
      account_id = maevsi.invoker_account_id()
    )
  OR
    id IN (SELECT upload_id FROM maevsi.profile_picture)
);

-- Only allow tusd to update rows.
CREATE POLICY upload_update_using ON maevsi.upload FOR UPDATE USING (
  (SELECT current_user) = :'role_maevsi_tusd_username'
);

-- Only allow tusd to delete rows.
CREATE POLICY upload_delete_using ON maevsi.upload FOR DELETE USING (
  (SELECT current_user) = :'role_maevsi_tusd_username'
);

COMMIT;
