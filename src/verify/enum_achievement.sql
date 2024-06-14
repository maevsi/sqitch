-- Verify maevsi:enum_achievement on pg

BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('maevsi.achievement', 'USAGE'));
END $$;

ROLLBACK;
