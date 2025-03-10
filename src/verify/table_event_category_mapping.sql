BEGIN;

SELECT event_id,
       category
FROM vibetype.event_category_mapping WHERE FALSE;

ROLLBACK;
