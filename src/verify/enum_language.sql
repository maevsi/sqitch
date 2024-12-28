BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('maevsi.language', 'USAGE'));
END $$;

ROLLBACK;
