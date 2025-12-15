BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres_role_service_vibetype_username`

CREATE TABLE vibetype_private.achievement_code (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  alias       TEXT NOT NULL CHECK (char_length(alias) <= 1000) UNIQUE,
  achievement vibetype.achievement_type NOT NULL
);

COMMENT ON TABLE vibetype_private.achievement_code IS 'Codes that unlock achievements.';
COMMENT ON COLUMN vibetype_private.achievement_code.id IS 'The code that unlocks an achievement.';
COMMENT ON COLUMN vibetype_private.achievement_code.alias IS 'An alternative code, e.g. human readable, that unlocks an achievement. Must not exceed 1,000 characters.';
COMMENT ON COLUMN vibetype_private.achievement_code.achievement IS 'The achievement that is unlocked by the code.';

GRANT SELECT ON TABLE vibetype_private.achievement_code TO :role_service_vibetype_username;

ALTER TABLE vibetype_private.achievement_code ENABLE ROW LEVEL SECURITY;

-- Make all achievement codes accessible.
CREATE POLICY achievement_code_select ON vibetype_private.achievement_code FOR SELECT
USING (
  TRUE
);

COMMIT;
