-- Deploy maevsi:table_achievement_code to pg
-- requires: schema_private
-- requires: schema_public
-- requires: enum_achievement
-- requires: role_tusd

BEGIN;

CREATE TABLE maevsi_private.achievement_code (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  alias       TEXT NOT NULL CHECK (char_length(alias) < 1000) UNIQUE,
  achievement maevsi.achievement NOT NULL
);

COMMENT ON TABLE maevsi_private.achievement_code IS 'Codes that unlock achievements.';
COMMENT ON COLUMN maevsi_private.achievement_code.id IS 'The code that unlocks an achievement.';
COMMENT ON COLUMN maevsi_private.achievement_code.alias IS 'An alternative code, e.g. human readable, that unlocks an achievement.';
COMMENT ON COLUMN maevsi_private.achievement_code.achievement IS 'The achievement that is unlocked by the code.';

GRANT SELECT ON TABLE maevsi_private.achievement_code TO maevsi_tusd;

ALTER TABLE maevsi_private.achievement_code ENABLE ROW LEVEL SECURITY;

-- TODO: replace role tusd by backend
-- Make all achievement codes accessible by tusd.
CREATE POLICY achievement_code_select ON maevsi_private.achievement_code FOR SELECT USING (
  TRUE
);

COMMIT;
