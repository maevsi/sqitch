BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.create_contacts(vibetype.contact[])', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.create_contacts(vibetype.contact[])', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.create_contact_groups(TEXT[])', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.create_contact_groups(TEXT[])', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.create_contact_group_members(UUID[], UUID[])', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.create_contact_group_members(UUID[], UUID[])', 'EXECUTE'));
END $$;

ROLLBACK;
