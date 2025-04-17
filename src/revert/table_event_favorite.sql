BEGIN;

DROP POLICY event_favorite_all ON vibetype.event_favorite;

DROP TABLE vibetype.event_favorite;

COMMIT;
