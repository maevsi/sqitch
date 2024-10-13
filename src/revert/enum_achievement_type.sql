-- Revert maevsi:enum_achievement_type from pg

BEGIN;

DROP TYPE maevsi.achievement_type;

COMMIT;
