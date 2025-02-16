BEGIN;

DROP POLICY event_favorite_delete ON maevsi.event_favorite;
DROP POLICY event_favorite_insert ON maevsi.event_favorite;
DROP POLICY event_favorite_select ON maevsi.event_favorite;

COMMIT;
