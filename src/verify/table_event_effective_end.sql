BEGIN;

SELECT effective_end FROM vibetype.event WHERE FALSE;

SELECT 1/COUNT(*)
FROM (
  SELECT col_description(
    'vibetype.event'::regclass,
    (SELECT ordinal_position FROM information_schema.columns WHERE table_schema = 'vibetype' AND table_name = 'event' AND column_name = 'effective_end')
  ) AS comment
) t
WHERE t.comment LIKE '@behavior -*%';

SELECT 1/count(*) FROM pg_indexes WHERE schemaname = 'vibetype' AND indexname = 'idx_event_start_effective_end';

ROLLBACK;
