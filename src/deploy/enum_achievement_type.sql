BEGIN;

CREATE TYPE maevsi.achievement_type AS ENUM (
  'early_bird',
  'meet_the_team'
);

COMMENT ON TYPE maevsi.achievement_type IS 'Achievements that can be unlocked by users.';

COMMIT;
