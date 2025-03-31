BEGIN;

SELECT event_id,
       category_id
FROM vibetype.event_category_mapping WHERE FALSE;

ROLLBACK;
