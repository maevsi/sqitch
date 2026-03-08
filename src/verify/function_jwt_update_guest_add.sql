BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.jwt_update_guest_add(UUID)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.jwt_update_guest_add(UUID)', 'EXECUTE'));
END $$;

ROLLBACK;
