-- Revert maevsi:enum_event_category from pg

BEGIN;

DROP TYPE maevsi.event_category;

COMMIT;
