BEGIN;

DO $$
BEGIN
  ASSERT to_regclass('vibetype_private.notification') IS NULL;
  ASSERT to_regprocedure('vibetype.notification_acknowledge(UUID, BOOLEAN)') IS NULL;
END $$;

ROLLBACK;
