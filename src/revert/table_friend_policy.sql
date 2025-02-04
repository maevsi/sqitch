BEGIN;

DROP POLICY friend_select ON maevsi.friend;
DROP POLICY friend_insert ON maevsi.friend;
DROP POLICY friend_update ON maevsi.friend;

COMMIT;
