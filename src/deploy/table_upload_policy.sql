BEGIN;

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
    (
      NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NOT NULL
      AND
      account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
    )
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
