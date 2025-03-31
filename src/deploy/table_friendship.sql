BEGIN;

CREATE TABLE vibetype.friendship (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  a_account_id        UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,
  b_account_id        UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,
  status              vibetype.friendship_status NOT NULL DEFAULT 'requested'::vibetype.friendship_status,

  created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by          UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,
  updated_at          TIMESTAMP WITH TIME ZONE,
  updated_by          UUID REFERENCES vibetype.account(id) ON DELETE SET NULL,

  UNIQUE (a_account_id, b_account_id),
  CONSTRAINT friendship_creator_participant CHECK (created_by = a_account_id or created_by = b_account_id),
  CONSTRAINT friendship_creator_updater_difference CHECK (created_by <> updated_by),
  CONSTRAINT friendship_ordering CHECK (a_account_id < b_account_id),
  CONSTRAINT friendship_updater_participant CHECK (updated_by IS NULL or updated_by = a_account_id or updated_by = b_account_id)
);

CREATE INDEX idx_friendship_created_by ON vibetype.friendship USING btree (created_by);
CREATE INDEX idx_friendship_updated_by ON vibetype.friendship USING btree (updated_by);

COMMENT ON TABLE vibetype.friendship IS 'A friend relation together with its status.';
COMMENT ON COLUMN vibetype.friendship.id IS E'@omit create,update\nThe friend relation''s internal id.';
COMMENT ON COLUMN vibetype.friendship.a_account_id IS E'@omit update\nThe ''left'' side of the friend relation. It must be lexically less than the ''right'' side.';
COMMENT ON COLUMN vibetype.friendship.b_account_id IS E'@omit update\nThe ''right'' side of the friend relation. It must be lexically greater than the ''left'' side.';
COMMENT ON COLUMN vibetype.friendship.status IS E'@omit create\nThe status of the friend relation.';
COMMENT ON COLUMN vibetype.friendship.created_at IS E'@omit create,update\nThe timestamp when the friend relation was created.';
COMMENT ON COLUMN vibetype.friendship.created_by IS E'@omit update\nThe account that created the friend relation was created.';
COMMENT ON COLUMN vibetype.friendship.updated_at IS E'@omit create,update\nThe timestamp when the friend relation''s status was updated.';
COMMENT ON COLUMN vibetype.friendship.updated_by IS E'@omit create,update\nThe account that updated the friend relation''s status.';
COMMENT ON INDEX vibetype.idx_friendship_created_by IS 'B-Tree index to optimize lookups by creator.';
COMMENT ON INDEX vibetype.idx_friendship_updated_by IS 'B-Tree index to optimize lookups by updater.';

CREATE TRIGGER vibetype_trigger_friendship_update
  BEFORE
    UPDATE
  ON vibetype.friendship
  FOR EACH ROW
  EXECUTE PROCEDURE vibetype.trigger_metadata_update();

COMMIT;
