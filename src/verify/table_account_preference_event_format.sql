BEGIN;

SELECT a.account_id,
       a.format_id,
       a.created_at,
       f.name
FROM vibetype.account_preference_event_format a
  JOIN vibetype.event_format f ON a.format_id = f.id
WHERE FALSE;

ROLLBACK;
