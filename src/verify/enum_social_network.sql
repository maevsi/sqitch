BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('vibetype.social_network', 'USAGE'));
END $$;

ROLLBACK;
