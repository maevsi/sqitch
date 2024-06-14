-- Verify maevsi:enum_achievement_type on pg

BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('maevsi.achievement_type', 'USAGE'));
END $$;

ROLLBACK;
