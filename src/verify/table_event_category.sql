BEGIN;

SELECT category
FROM vibetype.event_category WHERE FALSE;

ROLLBACK;
