-- Deploy maevsi:enum_achievement to pg
-- requires: schema_public

BEGIN;

CREATE TYPE maevsi.achievement AS ENUM (
  'meet_the_team'
);

COMMENT ON TYPE maevsi.achievement IS 'Achievements that can be unlocked by users.';

COMMIT;
