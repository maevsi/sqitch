-- Deploy maevsi:enum_achievement_type to pg
-- requires: schema_public

BEGIN;

CREATE TYPE maevsi.achievement_type AS ENUM (
  'meet_the_team'
);

COMMENT ON TYPE maevsi.achievement_type IS 'Achievements that can be unlocked by users.';

COMMIT;
