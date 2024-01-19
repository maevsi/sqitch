-- Verify maevsi:table_event_category_mapping on pg

BEGIN;

SELECT event_id,
       category
FROM maevsi.table_event_category_mapping WHERE FALSE;

ROLLBACK;
