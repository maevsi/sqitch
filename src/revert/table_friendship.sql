BEGIN;

-- vibetype.friendship

DROP POLICY friendship_not_blocked ON vibetype.friendship;
DROP POLICY friendship_select ON vibetype.friendship;
DROP POLICY friendship_insert ON vibetype.friendship;
DROP POLICY friendship_update ON vibetype.friendship;
DROP POLICY friendship_delete ON vibetype.friendship;

DROP TRIGGER vibetype_trigger_friendship_update ON vibetype.friendship;

DROP INDEX vibetype.idx_friendship_updated_by;
DROP INDEX vibetype.idx_friendship_created_by;
DROP TABLE vibetype.friendship;

-- vibetype.friendship_request

DROP POLICY friendship_request_not_blocked ON vibetype.friendship_request;
DROP POLICY friendship_request_select ON vibetype.friendship_request;
DROP POLICY friendship_request_insert ON vibetype.friendship_request;
DROP POLICY friendship_request_delete ON vibetype.friendship_request;

DROP TABLE vibetype.friendship_request;

COMMIT;
