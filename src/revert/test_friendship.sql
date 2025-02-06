BEGIN;

DROP FUNCTION maevsi_test.friendship_account_create(TEXT, TEXT);

DROP FUNCTION maevsi_test.friendship_accept(UUID, UUID);
DROP FUNCTION maevsi_test.friendship_reject(UUID, UUID);
DROP FUNCTION maevsi_test.friendship_request(UUID, UUID);

DROP FUNCTION maevsi_test.friendship_test (TEXT, UUID, TEXT, UUID[]);
DROP FUNCTION maevsi_test.friendship_account_ids_test (TEXT, UUID, UUID[]);

END;
