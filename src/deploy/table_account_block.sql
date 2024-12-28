BEGIN;

CREATE TABLE maevsi.account_block (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_account_id   UUID NOT NULL REFERENCES maevsi.account(id),
  blocked_account_id  UUID NOT NULL REFERENCES maevsi.account(id),
  created_at          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (author_account_id, blocked_account_id),
  CHECK (author_account_id != blocked_account_id)
);

COMMENT ON TABLE maevsi.account_block IS E'@omit update,delete\nBlocking of an account by another account.';
COMMENT ON COLUMN maevsi.account_block.id IS '@omit create\nThe blocking''s internal id.';
COMMENT ON COLUMN maevsi.account_block.author_account_id IS 'The id of the user who created the blocking.';
COMMENT ON COLUMN maevsi.account_block.blocked_account_id IS 'The id of the account to be blocked.';
COMMENT ON COLUMN maevsi.account_block.created_at IS E'@omit create,update,delete\nThe timestamp when the blocking was created.';

COMMIT;
