BEGIN;

DROP FUNCTION vibetype_test.friendship_accept(UUID, UUID);
DROP FUNCTION vibetype_test.friendship_reject(UUID, UUID);
DROP FUNCTION vibetype_test.friendship_request(UUID, UUID);

DROP FUNCTION vibetype_test.friendship_test(TEXT, UUID, TEXT, UUID[]);
DROP FUNCTION vibetype_test.friendship_account_ids_test(TEXT, UUID, UUID[]);

END;
