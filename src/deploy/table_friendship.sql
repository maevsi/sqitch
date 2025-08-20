BEGIN;

-----------------------------------------------------------
-- TABLE vibetype.friendship_request
-----------------------------------------------------------

CREATE TABLE vibetype.friendship_request (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id          UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,
  friend_account_id   UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,
  created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by          UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,

  UNIQUE (account_id, friend_account_id),
  CONSTRAINT friendship_creator_friend CHECK (account_id <> friend_account_id),
  CONSTRAINT friendship_creator_participant CHECK (created_by = account_id)
);

GRANT SELECT, INSERT, DELETE ON TABLE vibetype.friendship_request TO vibetype_account;

ALTER TABLE vibetype.friendship_request ENABLE ROW LEVEL SECURITY;

CREATE POLICY friendship_request_not_blocked ON vibetype.friendship_request AS RESTRICTIVE FOR ALL
USING (
  account_id NOT IN (SELECT id FROM vibetype_private.account_block_ids())
  AND friend_account_id NOT IN (SELECT id FROM vibetype_private.account_block_ids())
);

-- Only allow interactions with friendships in which the current user is involved.
CREATE POLICY friendship_request_select ON vibetype.friendship_request FOR SELECT
USING (
  account_id = vibetype.invoker_account_id()
  OR
  friend_account_id = vibetype.invoker_account_id()
);

-- Only allow creation by the current user.
CREATE POLICY friendship_request_insert ON vibetype.friendship_request FOR INSERT
WITH CHECK (
  created_by = vibetype.invoker_account_id()
);

CREATE POLICY friendship_request_delete ON vibetype.friendship_request FOR DELETE
USING (
  friend_account_id = vibetype.invoker_account_id()
);

-----------------------------------------------------------
-- TABLE vibetype.friendship
-----------------------------------------------------------

CREATE TABLE vibetype.friendship (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  account_id          UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,
  friend_account_id   UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,

  created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by          UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,

  UNIQUE (account_id, friend_account_id),
  CONSTRAINT friendship_creator_friend CHECK (account_id <> friend_account_id),
  CONSTRAINT friendship_creator_participant CHECK (created_by = account_id)
);

CREATE INDEX idx_friendship_created_by ON vibetype.friendship USING btree (created_by);

COMMENT ON TABLE vibetype.friendship IS 'A friend relation together with its status.';
COMMENT ON COLUMN vibetype.friendship.id IS E'@omit create,update\nThe friend relation''s internal id.';
COMMENT ON COLUMN vibetype.friendship.account_id IS E'@omit update\nOne side of the friend relation.';
COMMENT ON COLUMN vibetype.friendship.friend_account_id IS E'@omit update\nThe other side of the friend relation.';
COMMENT ON COLUMN vibetype.friendship.created_at IS E'@omit create,update\nThe timestamp when the friend relation was created.';
COMMENT ON COLUMN vibetype.friendship.created_by IS E'@omit update\nThe account that created the friend relation was created.';
COMMENT ON INDEX vibetype.idx_friendship_created_by IS 'B-Tree index to optimize lookups by creator.';

GRANT SELECT, INSERT, DELETE ON TABLE vibetype.friendship TO vibetype_account;

ALTER TABLE vibetype.friendship ENABLE ROW LEVEL SECURITY;

CREATE POLICY friendship_not_blocked ON vibetype.friendship AS RESTRICTIVE FOR ALL
USING (
  account_id NOT IN (SELECT id FROM vibetype_private.account_block_ids())
  AND friend_account_id NOT IN (SELECT id FROM vibetype_private.account_block_ids())
);

-- Only allow interactions with friendships in which the current user is involved.
CREATE POLICY friendship_select ON vibetype.friendship FOR SELECT
USING (
  TRUE
);

-- Only allow creation by the current user and only if a friendship request is present.
CREATE POLICY friendship_insert ON vibetype.friendship FOR INSERT
WITH CHECK (
  (account_id, friend_account_id, created_by) IN (
    SELECT account_id, friend_account_id, account_id
    FROM vibetype.friendship_request
    WHERE friend_account_id = vibetype.invoker_account_id()
  )
  OR
  (account_id, friend_account_id, created_by) IN (
    SELECT friend_account_id, account_id, friend_account_id
    FROM vibetype.friendship_request
    WHERE friend_account_id = vibetype.invoker_account_id()
  )
);

-- Only allow deletion if the current user is involved in the friendship.
CREATE POLICY friendship_delete ON vibetype.friendship FOR DELETE
USING (
  account_id = vibetype.invoker_account_id()
  OR
  friend_account_id = vibetype.invoker_account_id()
);

-----------------------------------------------------------
-- TABLE vibetype.friendship_closeness
-----------------------------------------------------------

CREATE TABLE vibetype.friendship_closeness (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  account_id          UUID NOT NULL,
  friend_account_id   UUID NOT NULL,

  is_close_friend     BOOLEAN NOT NULL DEFAuLT FALSE,

  created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by          UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,
  updated_at          TIMESTAMP WITH TIME ZONE,
  updated_by          UUID REFERENCES vibetype.account(id) ON DELETE SET NULL,

  UNIQUE (account_id, friend_account_id),
  CONSTRAINT fk_friendship_closeness FOREIGN KEY (account_id, friend_account_id) REFERENCES vibetype.friendship(account_id, friend_account_id) ON DELETE CASCADE,
  CONSTRAINT friendship_closeness_creator CHECK (created_by = account_id),
  CONSTRAINT friendship_closeness_updater CHECK (updated_by = account_id)
);

CREATE INDEX idx_friendship_closeness_created_by ON vibetype.friendship_closeness USING btree (created_by);
CREATE INDEX idx_friendship_closeness_updated_by ON vibetype.friendship_closeness USING btree (updated_by);

COMMENT ON TABLE vibetype.friendship_closeness IS 'The presence of a row in this tables indicates that account_id considers friend_account_id as a close friend.';
COMMENT ON COLUMN vibetype.friendship_closeness.id IS E'@omit create,update\nThe friend relation''s internal id.';
COMMENT ON COLUMN vibetype.friendship_closeness.account_id IS E'@omit update\nThe one side of the friend relation. If the status is ''requested'' then it is the requestor account.';
COMMENT ON COLUMN vibetype.friendship_closeness.friend_account_id IS E'@omit update\nThe other side of the friend relation. If the status is ''requested'' then it is the requestee account.';
COMMENT ON COLUMN vibetype.friendship_closeness.is_close_friend IS E'@omit create\nThe flag indicating whether account_id considers friend_account_id as a close friend or not.';
COMMENT ON COLUMN vibetype.friendship_closeness.created_at IS E'@omit create,update\nThe timestamp when the friend relation was created.';
COMMENT ON COLUMN vibetype.friendship_closeness.created_by IS E'@omit update\nThe account that created the friend relation was created.';
COMMENT ON COLUMN vibetype.friendship_closeness.updated_at IS E'@omit create,update\nThe timestamp when the friend relation''s closeness status was updated.';
COMMENT ON COLUMN vibetype.friendship_closeness.updated_by IS E'@omit create,update\nThe account that updated the friend relation''s closeness status.';

CREATE TRIGGER vibetype_trigger_friendship_closeness_update
  BEFORE
    UPDATE
  ON vibetype.friendship_closeness
  FOR EACH ROW
  EXECUTE PROCEDURE vibetype.trigger_metadata_update();

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE vibetype.friendship_closeness TO vibetype_account;

ALTER TABLE vibetype.friendship_closeness ENABLE ROW LEVEL SECURITY;

CREATE POLICY friendship_closeness_not_blocked ON vibetype.friendship_closeness AS RESTRICTIVE FOR ALL
USING (
  account_id NOT IN (SELECT id FROM vibetype_private.account_block_ids())
  AND friend_account_id NOT IN (SELECT id FROM vibetype_private.account_block_ids())
);

-- Only allow selection of close friends of the current account.
CREATE POLICY friendship_closeness_select ON vibetype.friendship_closeness FOR SELECT
USING (
  account_id = vibetype.invoker_account_id()
);

-- Only allow creation by the current user and only if a friendship request is present.
CREATE POLICY friendship_closeness_insert ON vibetype.friendship_closeness FOR INSERT
WITH CHECK (
  account_id = vibetype.invoker_account_id()
  OR
  friend_account_id = vibetype.invoker_account_id()
);

CREATE POLICY friendship_closeness_update ON vibetype.friendship_closeness FOR UPDATE
USING (
  account_id = vibetype.invoker_account_id()
)
WITH CHECK (
  updated_by = vibetype.invoker_account_id()
);

-- Only allow deletion if the current user is involved in the friendship.
CREATE POLICY friendship_closeness_delete ON vibetype.friendship_closeness FOR DELETE
USING (
  account_id = vibetype.invoker_account_id()
);

COMMIT;
