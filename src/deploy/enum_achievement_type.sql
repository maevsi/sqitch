BEGIN;

CREATE TYPE maevsi.achievement_type AS ENUM (
  'meet_the_team',
  'early_bird'
);

COMMENT ON TYPE maevsi.achievement_type IS 'Achievements that can be unlocked by users.';

COMMIT;
