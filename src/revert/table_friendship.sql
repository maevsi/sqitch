BEGIN;

DROP INDEX maevsi.idx_friendship_updated_by;
DROP INDEX maevsi.idx_friendship_created_by;
DROP TABLE maevsi.friendship;

COMMIT;
