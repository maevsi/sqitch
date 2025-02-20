BEGIN;

DROP POLICY friendship_update ON maevsi.friendship;
DROP POLICY friendship_insert ON maevsi.friendship;
DROP POLICY friendship_existing ON maevsi.friendship;

COMMIT;
