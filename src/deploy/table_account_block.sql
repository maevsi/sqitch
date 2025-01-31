BEGIN;

CREATE TABLE maevsi.account_block (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  blocked_account_id  UUID NOT NULL REFERENCES maevsi.account(id),

  created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by          UUID NOT NULL REFERENCES maevsi.account(id),

  UNIQUE (created_by, blocked_account_id),
  CHECK (created_by != blocked_account_id)
);

COMMENT ON TABLE maevsi.account_block IS E'@omit update,delete\nBlocking of one account by another.';
COMMENT ON COLUMN maevsi.account_block.id IS '@omit create\nThe account blocking''s internal id.';
COMMENT ON COLUMN maevsi.account_block.blocked_account_id IS 'The account id of the user who is blocked.';
COMMENT ON COLUMN maevsi.account_block.created_at IS E'@omit create,update,delete\nTimestamp of when the blocking was created.';
COMMENT ON COLUMN maevsi.account_block.created_by IS 'The account id of the user who created the blocking.';

COMMIT;
