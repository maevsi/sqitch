BEGIN;

-- vibetype.friendship_closeness

DROP POLICY friendship_closeness_not_blocked ON vibetype.friendship_closeness;
DROP POLICY friendship_closeness_select ON vibetype.friendship_closeness;
DROP POLICY friendship_closeness_insert ON vibetype.friendship_closeness;
DROP POLICY friendship_closeness_update ON vibetype.friendship_closeness;
DROP POLICY friendship_closeness_delete ON vibetype.friendship_closeness;

DROP INDEX vibetype.idx_friendship_closeness_updated_by;
DROP INDEX vibetype.idx_friendship_closeness_created_by;

DROP TRIGGER vibetype_trigger_friendship_closeness_update ON vibetype.friendship_closeness;

DROP TABLE vibetype.friendship_closeness;

-- vibetype.friendship

DROP POLICY friendship_not_blocked ON vibetype.friendship;
DROP POLICY friendship_select ON vibetype.friendship;
DROP POLICY friendship_insert ON vibetype.friendship;
DROP POLICY friendship_delete ON vibetype.friendship;

DROP INDEX vibetype.idx_friendship_created_by;

DROP TABLE vibetype.friendship;

-- vibetype.friendship_request

DROP POLICY friendship_request_not_blocked ON vibetype.friendship_request;
DROP POLICY friendship_request_select ON vibetype.friendship_request;
DROP POLICY friendship_request_insert ON vibetype.friendship_request;
DROP POLICY friendship_request_delete ON vibetype.friendship_request;

DROP TABLE vibetype.friendship_request;

COMMIT;
