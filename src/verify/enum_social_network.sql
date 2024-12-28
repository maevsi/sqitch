BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('maevsi.social_network', 'USAGE'));
END $$;

ROLLBACK;
