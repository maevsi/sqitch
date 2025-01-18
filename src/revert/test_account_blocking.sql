BEGIN;

DROP FUNCTION maevsi_test.account_block_create(UUID, UUID);
DROP FUNCTION maevsi_test.account_block_remove(UUID, UUID);
DROP FUNCTION maevsi_test.account_create(TEXT, TEXT);
DROP FUNCTION maevsi_test.account_remove(TEXT);
DROP FUNCTION maevsi_test.contact_create(UUID, TEXT);
DROP FUNCTION maevsi_test.contact_select_by_account_id(UUID);
DROP FUNCTION maevsi_test.contact_test(TEXT, UUID, UUID[]);
DROP FUNCTION maevsi_test.event_category_create(TEXT);
DROP FUNCTION maevsi_test.event_category_mapping_create(UUID, UUID, TEXT);
DROP FUNCTION maevsi_test.event_category_mapping_test(TEXT, UUID, UUID[]);
DROP FUNCTION maevsi_test.event_create(UUID, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION maevsi_test.event_test(TEXT, UUID, UUID[]);
DROP FUNCTION maevsi_test.invitation_create(UUID, UUID, UUID);
DROP FUNCTION maevsi_test.invitation_test(TEXT, UUID, UUID[]);

COMMIT;