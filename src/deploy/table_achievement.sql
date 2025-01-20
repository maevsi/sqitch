BEGIN;

CREATE TABLE maevsi.achievement (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  account_id  UUID NOT NULL REFERENCES maevsi.account(id),
  achievement maevsi.achievement_type NOT NULL,
  level       INTEGER NOT NULL CHECK (level > 0) DEFAULT 1,

  UNIQUE (account_id, achievement)
);

COMMENT ON TABLE maevsi.achievement IS 'Achievements unlocked by users.';
COMMENT ON COLUMN maevsi.achievement.id IS 'The achievement unlock''s internal id.';
COMMENT ON COLUMN maevsi.achievement.account_id IS 'The account which unlocked the achievement.';
COMMENT ON COLUMN maevsi.achievement.achievement IS 'The unlock''s achievement.';
COMMENT ON COLUMN maevsi.achievement.level IS 'The achievement unlock''s level.';

GRANT SELECT ON TABLE maevsi.achievement TO maevsi_account, maevsi_anonymous;

ALTER TABLE maevsi.achievement ENABLE ROW LEVEL SECURITY;

-- Make all achievement unlocks accessible by everyone.
CREATE POLICY achievement_select ON maevsi.achievement FOR SELECT USING (
  TRUE
);

COMMIT;
