BEGIN;

DROP INDEX maevsi.idx_event_grouping_event_id;
DROP INDEX maevsi.idx_event_grouping_event_group_id;
DROP TABLE maevsi.event_grouping;

COMMIT;
