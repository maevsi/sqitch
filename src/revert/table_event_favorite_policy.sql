BEGIN;

DROP POLICY event_favorite_delete ON vibetype.event_favorite;
DROP POLICY event_favorite_insert ON vibetype.event_favorite;
DROP POLICY event_favorite_select ON vibetype.event_favorite;

COMMIT;
