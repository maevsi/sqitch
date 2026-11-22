BEGIN;

SELECT vibetype_private.event_link_unlisted_id();

DO $$
BEGIN
  ASSERT EXISTS (SELECT 1 FROM pg_catalog.pg_policies WHERE schemaname = 'vibetype' AND tablename = 'event' AND policyname = 'event_select');
  ASSERT EXISTS (SELECT 1 FROM pg_catalog.pg_policies WHERE schemaname = 'vibetype' AND tablename = 'guest' AND policyname = 'guest_insert_join');
END $$;

ROLLBACK;
