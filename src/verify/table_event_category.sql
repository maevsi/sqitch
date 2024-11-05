-- Verify maevsi:table_event_category pg

BEGIN;

SELECT category
FROM maevsi.event_category WHERE FALSE;

ROLLBACK;