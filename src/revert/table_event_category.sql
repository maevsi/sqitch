-- Revert maevsi:table_event_category from pg

BEGIN;

DROP TABLE maevsi.event_category;

COMMIT;