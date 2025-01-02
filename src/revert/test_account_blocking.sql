BEGIN;

DROP FUNCTION maevsi_test.create_account (TEXT, TEXT);
DROP FUNCTION maevsi_test.remove_account (TEXT);
DROP FUNCTION maevsi_test.get_own_contact (UUID);
DROP FUNCTION maevsi_test.create_contact (UUID, TEXT);
DROP FUNCTION maevsi_test.create_event (UUID, TEXT, TEXT, TEXT, TEXT);
DROP FUNCTION maevsi_test.create_invitation (UUID, UUID, UUID);
DROP FUNCTION maevsi_test.block_account (UUID, UUID);
DROP FUNCTION maevsi_test.unblock_account (UUID, UUID);
DROP FUNCTION maevsi_test.select_events (TEXT, TEXT, UUID, UUID[]);
DROP FUNCTION maevsi_test.select_contacts (TEXT, TEXT, UUID, UUID[]);
DROP FUNCTION maevsi_test.select_invitations (TEXT, TEXT, UUID, UUID[]);

COMMIT;
