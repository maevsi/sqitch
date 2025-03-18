BEGIN;

GRANT SELECT ON TABLE vibetype.upload TO vibetype_account, vibetype_anonymous, vibetype_tusd;
GRANT UPDATE ON TABLE vibetype.upload TO vibetype_tusd;
GRANT DELETE ON TABLE vibetype.upload TO vibetype_tusd;

ALTER TABLE vibetype.upload ENABLE ROW LEVEL SECURITY;

-- Display
-- - all uploads for `tusd` or
-- - the uploads that are linked to the requesting account or
-- - the uploads which are used as profile picture.
CREATE POLICY upload_select_using ON vibetype.upload FOR SELECT USING (
    (SELECT current_user) = 'vibetype_tusd'
  OR
    (
      vibetype.invoker_account_id() IS NOT NULL
      AND
      account_id = vibetype.invoker_account_id()
    )
  OR
    id IN (SELECT upload_id FROM vibetype.profile_picture)
);

-- Only allow tusd to update rows.
CREATE POLICY upload_update_using ON vibetype.upload FOR UPDATE USING (
  (SELECT current_user) = 'vibetype_tusd'
);

-- Only allow tusd to delete rows.
CREATE POLICY upload_delete_using ON vibetype.upload FOR DELETE USING (
  (SELECT current_user) = 'vibetype_tusd'
);

COMMIT;
