BEGIN;

DROP POLICY friendship_update ON vibetype.friendship;
DROP POLICY friendship_insert ON vibetype.friendship;
DROP POLICY friendship_existing ON vibetype.friendship;

DROP TRIGGER vibetype_trigger_friendship_update ON vibetype.friendship;

DROP INDEX vibetype.idx_friendship_updated_by;
DROP INDEX vibetype.idx_friendship_created_by;
DROP TABLE vibetype.friendship;

COMMIT;
