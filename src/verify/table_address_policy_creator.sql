BEGIN;

DO $$
BEGIN
  ASSERT EXISTS (SELECT 1 FROM pg_catalog.pg_policies WHERE schemaname = 'vibetype' AND tablename = 'address' AND policyname = 'address_delete_creator' AND permissive = 'RESTRICTIVE');
  ASSERT EXISTS (SELECT 1 FROM pg_catalog.pg_policies WHERE schemaname = 'vibetype' AND tablename = 'address' AND policyname = 'address_update_creator' AND permissive = 'RESTRICTIVE');
END $$;

ROLLBACK;
