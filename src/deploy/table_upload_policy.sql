BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres_role_service_vibetype_username`

GRANT SELECT ON TABLE vibetype.upload TO vibetype_account, vibetype_anonymous;
GRANT SELECT, UPDATE, DELETE ON TABLE vibetype.upload TO :role_service_vibetype_username;

ALTER TABLE vibetype.upload ENABLE ROW LEVEL SECURITY;

-- Allow the service role to select, update, or delete rows.
CREATE POLICY upload_all_service ON vibetype.upload FOR ALL
TO :role_service_vibetype_username
USING (
  TRUE
);

-- Display
-- - the uploads that are linked to the requesting account or
-- - the uploads which are used as profile picture.
CREATE POLICY upload_select ON vibetype.upload FOR SELECT USING (
    account_id = vibetype.invoker_account_id()
  OR
    id IN (SELECT upload_id FROM vibetype.profile_picture)
);


COMMIT;
