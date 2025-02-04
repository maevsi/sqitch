BEGIN;

DROP POLICY friend_update ON maevsi.friendship;
DROP POLICY friend_insert ON maevsi.friendship;
DROP POLICY friend_select ON maevsi.friendship;

COMMIT;
