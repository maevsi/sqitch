BEGIN;

DROP POLICY friendship_existing ON vibetype.friendship;
DROP POLICY friendship_insert ON vibetype.friendship;
DROP POLICY friendship_update ON vibetype.friendship;

ALTER TABLE vibetype.friendship RENAME COLUMN a_account_id TO account_a_id;
ALTER TABLE vibetype.friendship RENAME COLUMN b_account_id TO account_b_id;
ALTER TABLE vibetype.friendship RENAME CONSTRAINT friendship_a_account_id_b_account_id_key TO friendship_account_a_id_account_b_id_key;
ALTER TABLE vibetype.friendship RENAME CONSTRAINT friendship_a_account_id_fkey TO friendship_account_a_id_fkey;
ALTER TABLE vibetype.friendship RENAME CONSTRAINT friendship_b_account_id_fkey TO friendship_account_b_id_fkey;
ALTER INDEX vibetype.idx_friendship_b_account_id RENAME TO idx_friendship_account_b_id;

COMMENT ON TYPE vibetype.friendship_status IS 'Possible status values of a friendship.
There is no status `rejected` because the friendship is deleted when its request is rejected.';

COMMENT ON TABLE vibetype.friendship IS 'A friendship between two accounts. A row with status `requested` is a pending friend request by `created_by`, which the other account accepts by setting the status to `accepted`. Deleting the row withdraws or rejects a request, or ends the friendship.';
COMMENT ON COLUMN vibetype.friendship.id IS E'@behavior -insert -update\nThe friendship''s internal id.';
COMMENT ON COLUMN vibetype.friendship.account_a_id IS E'@behavior -update\nThe friendship''s account with the lexically smaller id.';
COMMENT ON COLUMN vibetype.friendship.account_b_id IS E'@behavior -update\nThe friendship''s account with the lexically greater id.';
COMMENT ON COLUMN vibetype.friendship.status IS E'@behavior -insert\nThe friendship''s status.';
COMMENT ON COLUMN vibetype.friendship.created_at IS E'@behavior -insert -update\nTimestamp of when the friendship was requested.';
COMMENT ON COLUMN vibetype.friendship.created_by IS E'@behavior -update\nThe account that requested the friendship.';
COMMENT ON COLUMN vibetype.friendship.updated_at IS E'@behavior -insert -update\nTimestamp of when the friendship was accepted.';
COMMENT ON COLUMN vibetype.friendship.updated_by IS E'@behavior -insert -update\nThe account that accepted the friendship.';
COMMENT ON INDEX vibetype.idx_friendship_account_b_id IS 'B-Tree index to optimize lookups by the second account.';

-- Accepted friendships are visible to every account, requested ones to their two accounts only.
-- Friendships involving an account that blocked or is blocked by the invoker are hidden.
CREATE POLICY friendship_select ON vibetype.friendship FOR SELECT
USING (
  (
    status = 'accepted'::vibetype.friendship_status
    OR account_a_id = vibetype.invoker_account_id()
    OR account_b_id = vibetype.invoker_account_id()
  )
  AND NOT EXISTS (
    SELECT 1 FROM unnest((SELECT vibetype_private.account_block_ids())) AS b
    WHERE b = friendship.account_a_id OR b = friendship.account_b_id
  )
);

-- Only allow requesting a friendship as oneself with an account that is not involved in a block.
-- `friendship_creator_participant` makes the invoker one of the two accounts.
CREATE POLICY friendship_insert ON vibetype.friendship FOR INSERT
WITH CHECK (
  created_by = vibetype.invoker_account_id()
  AND status = 'requested'::vibetype.friendship_status
  AND NOT EXISTS (
    SELECT 1 FROM unnest((SELECT vibetype_private.account_block_ids())) AS b
    WHERE b = friendship.account_a_id OR b = friendship.account_b_id
  )
);

-- Only allow the requested account to accept the request.
CREATE POLICY friendship_update ON vibetype.friendship FOR UPDATE
USING (
  status = 'requested'::vibetype.friendship_status
  AND created_by <> vibetype.invoker_account_id()
  AND (
    account_a_id = vibetype.invoker_account_id()
    OR account_b_id = vibetype.invoker_account_id()
  )
)
WITH CHECK (
  status = 'accepted'::vibetype.friendship_status
);

-- Only allow the two accounts to withdraw or reject the request, or to end the friendship.
CREATE POLICY friendship_delete ON vibetype.friendship FOR DELETE
USING (
  account_a_id = vibetype.invoker_account_id()
  OR account_b_id = vibetype.invoker_account_id()
);

COMMIT;
