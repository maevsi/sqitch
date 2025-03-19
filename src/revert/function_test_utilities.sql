BEGIN;

DROP PROCEDURE vibetype_test.set_local_superuser();
DROP FUNCTION vibetype_test.account_block_create(UUID, UUID);
DROP FUNCTION vibetype_test.account_block_remove(UUID, UUID);
DROP FUNCTION vibetype_test.account_create(TEXT, TEXT);
DROP FUNCTION vibetype_test.account_remove(TEXT);
DROP FUNCTION vibetype_test.contact_create(UUID, TEXT);
DROP FUNCTION vibetype_test.contact_select_by_account_id(UUID);
DROP FUNCTION vibetype_test.contact_test(TEXT, UUID, UUID[]);
DROP FUNCTION vibetype_test.event_category_create(TEXT);
DROP FUNCTION vibetype_test.event_category_mapping_create(UUID, UUID, TEXT);
DROP FUNCTION vibetype_test.event_category_mapping_test(TEXT, UUID, UUID[]);
DROP FUNCTION vibetype_test.event_create(UUID, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION vibetype_test.event_test(TEXT, UUID, UUID[]);
DROP FUNCTION vibetype_test.guest_create(UUID, UUID, UUID);
DROP FUNCTION vibetype_test.guest_test(TEXT, UUID, UUID[]);
DROP FUNCTION vibetype_test.guest_claim_from_account_guest(UUID);
DROP FUNCTION vibetype_test.invoker_set(UUID);
DROP FUNCTION vibetype_test.invoker_unset();
DROP FUNCTION vibetype_test.uuid_array_test(TEXT, UUID[], UUID[]);

COMMIT;
