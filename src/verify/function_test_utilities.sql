BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_test.account_create(TEXT, TEXT)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_test.account_remove(TEXT)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_test.contact_select_by_account_id(UUID)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_test.contact_create(UUID, TEXT)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_test.event_create(UUID, TEXT, TEXT, TEXT, TEXT)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_test.guest_create(UUID, UUID, UUID)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_test.event_category_create(TEXT)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_test.event_category_mapping_create(UUID, UUID, TEXT)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_test.account_block_create(UUID, UUID)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_test.account_block_remove(UUID, UUID)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_test.event_test(TEXT, UUID, UUID[])', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_test.event_category_mapping_test(TEXT, UUID, UUID[])', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_test.contact_test(TEXT, UUID, UUID[])', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_test.guest_test(TEXT, UUID, UUID[])', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_test.guest_claim_from_account_guest(UUID)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_test.invoker_set(UUID)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_test.invoker_unset()', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_test.uuid_array_test(TEXT, UUID[], UUID[])', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_test.uuid_array_test(TEXT, UUID[], UUID[])', 'EXECUTE'));
END $$;

ROLLBACK;