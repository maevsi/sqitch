BEGIN;

DROP POLICY friendship_update ON vibetype.friendship;
DROP POLICY friendship_insert ON vibetype.friendship;
DROP POLICY friendship_existing ON vibetype.friendship;

COMMIT;
