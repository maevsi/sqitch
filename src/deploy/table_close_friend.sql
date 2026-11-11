BEGIN;

CREATE TABLE vibetype.close_friend (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  friendship_id   UUID NOT NULL REFERENCES vibetype.friendship(id) ON DELETE CASCADE,

  created_at      TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by      UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,

  UNIQUE (created_by, friendship_id)
);

CREATE INDEX idx_close_friend_created_by ON vibetype.close_friend USING btree (created_by);
CREATE INDEX idx_close_friend_friendship_id ON vibetype.close_friend USING btree (friendship_id);

COMMENT ON TABLE vibetype.close_friend IS E'@behavior -update\nAn account''s marking of a friend as close. The marking is private: the friend cannot see it, and each of the two friends marks the other independently. It ends together with the friendship.';
COMMENT ON COLUMN vibetype.close_friend.id IS E'@behavior -insert\nThe close friend marking''s internal id.';
COMMENT ON COLUMN vibetype.close_friend.friendship_id IS 'The friendship whose other account is marked as close.';
COMMENT ON COLUMN vibetype.close_friend.created_at IS E'@behavior -insert\nTimestamp of when the close friend marking was created.';
COMMENT ON COLUMN vibetype.close_friend.created_by IS 'The account that marked the friend as close.';
COMMENT ON INDEX vibetype.idx_close_friend_created_by IS 'B-Tree index to optimize lookups by creator.';
COMMENT ON INDEX vibetype.idx_close_friend_friendship_id IS 'B-Tree index to optimize lookups by friendship.';

GRANT INSERT, SELECT, DELETE ON TABLE vibetype.close_friend TO vibetype_account;

ALTER TABLE vibetype.close_friend ENABLE ROW LEVEL SECURITY;

-- Only the marking account sees its markings.
CREATE POLICY close_friend_select ON vibetype.close_friend FOR SELECT
USING (
  created_by = vibetype.invoker_account_id()
);

-- Only allow marking as oneself within an own, accepted friendship.
-- The friendship's select policy applies, so a friend involved in a block cannot be marked.
CREATE POLICY close_friend_insert ON vibetype.close_friend FOR INSERT
WITH CHECK (
  created_by = vibetype.invoker_account_id()
  AND EXISTS (
    SELECT 1
    FROM vibetype.friendship f
    WHERE f.id = close_friend.friendship_id
      AND f.status = 'accepted'::vibetype.friendship_status
      AND (
        f.account_a_id = vibetype.invoker_account_id()
        OR f.account_b_id = vibetype.invoker_account_id()
      )
  )
);

CREATE POLICY close_friend_delete ON vibetype.close_friend FOR DELETE
USING (
  created_by = vibetype.invoker_account_id()
);

COMMIT;
