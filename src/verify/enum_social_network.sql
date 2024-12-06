-- Verify maevsi:enum_social_network on pg

BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('maevsi.social_network', 'USAGE'));
END $$;

ROLLBACK;
