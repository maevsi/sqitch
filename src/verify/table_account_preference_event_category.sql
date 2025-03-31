BEGIN;

SELECT a.account_id,
       a.category_id,
       a.created_at,
       c.name
FROM vibetype.account_preference_event_category a
  JOIN vibetype.event_category c ON a.category_id = c.id
WHERE FALSE;

ROLLBACK;
