BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.device_register(TEXT, vibetype.device_platform, TEXT)', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.device_register(TEXT, vibetype.device_platform, TEXT)', 'EXECUTE'));
END $$;

ROLLBACK;
