BEGIN;

DROP FUNCTION vibetype.friendship_accept(UUID);
DROP FUNCTION vibetype.friendship_cancel(UUID);
DROP FUNCTION vibetype.friendship_reject(UUID);
DROP FUNCTION vibetype.friendship_request(UUID);
DROP FUNCTION vibetype.friendship_toggle_closeness(UUID);

COMMIT;
