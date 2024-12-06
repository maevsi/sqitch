-- Revert maevsi:table_achievement_code from pg

BEGIN;

DROP TABLE maevsi_private.achievement_code;

COMMIT;
