BEGIN;

DROP INDEX vibetype.idx_friendship_updated_by;
DROP INDEX vibetype.idx_friendship_created_by;
DROP TABLE vibetype.friendship;

COMMIT;
