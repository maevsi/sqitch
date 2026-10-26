BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_private.upload_is_own(UUID)', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype_private.upload_is_own(UUID)', 'EXECUTE'));
  ASSERT EXISTS (SELECT 1 FROM pg_catalog.pg_policies WHERE schemaname = 'vibetype' AND tablename = 'profile_picture' AND policyname = 'profile_picture_upload_own' AND permissive = 'RESTRICTIVE');
END $$;

ROLLBACK;
