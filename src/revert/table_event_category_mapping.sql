-- Revert maevsi:table_event_category_mapping from pg

BEGIN;

DROP TABLE maevsi.event_category_mapping;

COMMIT;
