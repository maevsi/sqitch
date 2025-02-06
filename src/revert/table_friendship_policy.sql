BEGIN;

DROP POLICY friendship_select ON maevsi.friendship;
DROP POLICY friendship_insert ON maevsi.friendship;
DROP POLICY friendship_update ON maevsi.friendship;

COMMIT;
