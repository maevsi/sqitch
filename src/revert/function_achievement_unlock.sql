-- Revert maevsi:function_achievement_unlock from pg

BEGIN;

DROP FUNCTION maevsi.achievement_unlock;

COMMIT;
