BEGIN;

DROP INDEX vibetype.idx_friendship_updated_by;
DROP INDEX vibetype.idx_friendship_created_by;

DROP POLICY friendship_update ON vibetype.friendship;
DROP POLICY friendship_insert ON vibetype.friendship;
DROP POLICY friendship_existing ON vibetype.friendship;

DROP TABLE vibetype.friendship;

COMMIT;
