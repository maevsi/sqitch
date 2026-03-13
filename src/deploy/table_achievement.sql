BEGIN;

CREATE TABLE vibetype.achievement (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  account_id  UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,
  achievement vibetype.achievement_type NOT NULL,
  level       INTEGER NOT NULL CHECK (level > 0) DEFAULT 1,

  UNIQUE (account_id, achievement)
);

CREATE INDEX idx_achievement_account_id ON vibetype.achievement USING btree (account_id);

COMMENT ON TABLE vibetype.achievement IS 'Achievements unlocked by users.';
COMMENT ON COLUMN vibetype.achievement.id IS 'The achievement unlock''s internal id.';
COMMENT ON COLUMN vibetype.achievement.account_id IS 'The account which unlocked the achievement.';
COMMENT ON COLUMN vibetype.achievement.achievement IS 'The unlock''s achievement.';
COMMENT ON COLUMN vibetype.achievement.level IS 'The achievement unlock''s level.';

GRANT SELECT ON TABLE vibetype.achievement TO vibetype_account, vibetype_anonymous;

ALTER TABLE vibetype.achievement ENABLE ROW LEVEL SECURITY;

-- Make all achievement unlocks accessible by everyone.
CREATE POLICY achievement_select ON vibetype.achievement FOR SELECT
USING (
  TRUE
);

COMMIT;
