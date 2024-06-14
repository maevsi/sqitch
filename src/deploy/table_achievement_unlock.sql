-- Deploy maevsi:table_achievement_unlock to pg
-- requires: schema_public
-- requires: table_account_public
-- requires: enum_achievement
-- requires: role_account
-- requires: role_anonymous

BEGIN;

CREATE TABLE maevsi.achievement_unlock (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id  UUID NOT NULL REFERENCES maevsi.account(id),
  achievement maevsi.achievement NOT NULL,
  level       INTEGER NOT NULL CHECK (level > 0) DEFAULT 1,
  UNIQUE (account_id, achievement)
);

COMMENT ON TABLE maevsi.achievement_unlock IS 'Achievements unlocked by users.';
COMMENT ON COLUMN maevsi.achievement_unlock.id IS 'The achievement unlock''s internal id.';
COMMENT ON COLUMN maevsi.achievement_unlock.account_id IS 'The account which unlocked the achievement.';
COMMENT ON COLUMN maevsi.achievement_unlock.achievement IS 'The unlock''s achievement.';
COMMENT ON COLUMN maevsi.achievement_unlock.level IS 'The achievement unlock''s level.';

GRANT SELECT ON TABLE maevsi.achievement_unlock TO maevsi_account, maevsi_anonymous;

ALTER TABLE maevsi.achievement_unlock ENABLE ROW LEVEL SECURITY;

-- Make all achievement unlocks accessible by everyone.
CREATE POLICY achievement_unlock_select ON maevsi.achievement_unlock FOR SELECT USING (
  TRUE
);

COMMIT;
