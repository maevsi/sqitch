-- Revert maevsi:enum_event_achievement from pg

BEGIN;

DROP TYPE maevsi.achievement;

COMMIT;
