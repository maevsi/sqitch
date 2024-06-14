-- Revert maevsi:table_achievement_unlock from pg

BEGIN;

DROP POLICY achievement_unlock_select ON maevsi.achievement_unlock;
DROP TABLE maevsi.achievement_unlock;

COMMIT;
