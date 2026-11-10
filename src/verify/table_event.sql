BEGIN;

SELECT id,
       address_id,
       description,
       "end",
       guest_count_maximum,
       is_archived,
       is_in_person,
       is_remote,
       name,
       slug,
       start,
       url,
       visibility,
       created_at,
       created_by
FROM vibetype.event WHERE FALSE;

SELECT 1/COUNT(*)
FROM pg_indexes
WHERE schemaname = 'vibetype' AND indexname = 'idx_event_name_trgm';

SELECT 1/COUNT(*)
FROM (SELECT obj_description('vibetype.event'::regclass, 'pg_class') AS comment) t
WHERE t.comment LIKE '@behavior +filter%';

SELECT 1/COUNT(*)
FROM (
  SELECT col_description(
    'vibetype.event'::regclass,
    (SELECT ordinal_position FROM information_schema.columns WHERE table_schema = 'vibetype' AND table_name = 'event' AND column_name = 'start')
  ) AS comment
) t
WHERE t.comment LIKE '@behavior +filterBy%';

SELECT 1/COUNT(*)
FROM (
  SELECT col_description(
    'vibetype.event'::regclass,
    (SELECT ordinal_position FROM information_schema.columns WHERE table_schema = 'vibetype' AND table_name = 'event' AND column_name = 'end')
  ) AS comment
) t
WHERE t.comment LIKE '@behavior +filterBy%';

ROLLBACK;
