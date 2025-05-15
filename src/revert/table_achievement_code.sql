BEGIN;

DROP POLICY achievement_code_select ON vibetype_private.achievement_code;

DROP TABLE vibetype_private.achievement_code;

COMMIT;
