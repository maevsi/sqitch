BEGIN;

DROP POLICY friendship_delete ON vibetype.friendship;
DROP POLICY friendship_update ON vibetype.friendship;
DROP POLICY friendship_insert ON vibetype.friendship;
DROP POLICY friendship_select ON vibetype.friendship;

COMMENT ON INDEX vibetype.idx_friendship_account_b_id IS NULL;

COMMENT ON COLUMN vibetype.friendship.updated_by IS E'@behavior -insert -update\nThe account that updated the friend relation''s status.';
COMMENT ON COLUMN vibetype.friendship.updated_at IS E'@behavior -insert -update\nThe timestamp when the friend relation''s status was updated.';
COMMENT ON COLUMN vibetype.friendship.created_by IS E'@behavior -update\nThe account that created the friend relation.';
COMMENT ON COLUMN vibetype.friendship.created_at IS E'@behavior -insert -update\nThe timestamp when the friend relation was created.';
COMMENT ON COLUMN vibetype.friendship.status IS E'@behavior -insert\nThe status of the friend relation.';
COMMENT ON COLUMN vibetype.friendship.account_b_id IS E'@behavior -update\nThe ''right'' side of the friend relation. It must be lexically greater than the ''left'' side.';
COMMENT ON COLUMN vibetype.friendship.account_a_id IS E'@behavior -update\nThe ''left'' side of the friend relation. It must be lexically less than the ''right'' side.';
COMMENT ON COLUMN vibetype.friendship.id IS E'@behavior -insert -update\nThe friend relation''s internal id.';
COMMENT ON TABLE vibetype.friendship IS 'A friend relation together with its status.';

COMMENT ON TYPE vibetype.friendship_status IS 'Possible status values of a friend relation.
There is no status `rejected` because friendship records will be deleted when a friendship request is rejected.';

ALTER INDEX vibetype.idx_friendship_account_b_id RENAME TO idx_friendship_b_account_id;
ALTER TABLE vibetype.friendship RENAME CONSTRAINT friendship_account_b_id_fkey TO friendship_b_account_id_fkey;
ALTER TABLE vibetype.friendship RENAME CONSTRAINT friendship_account_a_id_fkey TO friendship_a_account_id_fkey;
ALTER TABLE vibetype.friendship RENAME CONSTRAINT friendship_account_a_id_account_b_id_key TO friendship_a_account_id_b_account_id_key;
ALTER TABLE vibetype.friendship RENAME COLUMN account_b_id TO b_account_id;
ALTER TABLE vibetype.friendship RENAME COLUMN account_a_id TO a_account_id;

CREATE POLICY friendship_update ON vibetype.friendship FOR UPDATE
USING (
  status = 'requested'::vibetype.friendship_status
) WITH CHECK (
  status = 'accepted'::vibetype.friendship_status
  AND
  updated_by = vibetype.invoker_account_id()
);

CREATE POLICY friendship_insert ON vibetype.friendship FOR INSERT
WITH CHECK (
  created_by = vibetype.invoker_account_id()
);

CREATE POLICY friendship_existing ON vibetype.friendship FOR ALL
USING (
  (
    vibetype.invoker_account_id() = friendship.a_account_id
    AND NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.account_block_ids())) AS b WHERE b = friendship.b_account_id)
  )
  OR
  (
    vibetype.invoker_account_id() = friendship.b_account_id
    AND NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.account_block_ids())) AS b WHERE b = friendship.a_account_id)
  )
)
WITH CHECK (FALSE);

COMMIT;
