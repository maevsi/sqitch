-- Revert maevsi:enum_event_size from pg

BEGIN;

DROP TYPE maevsi.event_size;

COMMIT;
