BEGIN;

SELECT id, name
FROM vibetype.event_category WHERE FALSE;

ROLLBACK;
