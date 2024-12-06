-- Revert maevsi:table_achievement from pg

BEGIN;

DROP POLICY achievement_select ON maevsi.achievement;
DROP TABLE maevsi.achievement;

COMMIT;
