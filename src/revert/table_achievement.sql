BEGIN;

DROP POLICY achievement_select ON vibetype.achievement;
DROP TABLE vibetype.achievement;

COMMIT;
