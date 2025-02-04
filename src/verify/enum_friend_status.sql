BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('maevsi.friend_status', 'USAGE'));
END $$;

ROLLBACK;
