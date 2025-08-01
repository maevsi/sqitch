BEGIN;

DROP POLICY friendship_not_blocked ON vibetype.friendship;
DROP POLICY friendship_select ON vibetype.friendship;
DROP POLICY friendship_insert ON vibetype.friendship;
DROP POLICY friendship_update_accept ON vibetype.friendship;
DROP POLICY friendship_update_toggle_closeness ON vibetype.friendship;
DROP POLICY friendship_delete ON vibetype.friendship;

DROP TRIGGER vibetype_trigger_friendship_update ON vibetype.friendship;

DROP INDEX vibetype.idx_friendship_updated_by;
DROP INDEX vibetype.idx_friendship_created_by;
DROP TABLE vibetype.friendship;

COMMIT;
