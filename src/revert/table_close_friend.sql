BEGIN;

DROP POLICY close_friend_delete ON vibetype.close_friend;
DROP POLICY close_friend_insert ON vibetype.close_friend;
DROP POLICY close_friend_select ON vibetype.close_friend;

DROP TABLE vibetype.close_friend;

COMMIT;
