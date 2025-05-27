BEGIN;

CREATE TABLE vibetype.account_block (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  blocked_account_id  UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,

  created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by          UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,

  UNIQUE (created_by, blocked_account_id),
  CHECK (created_by != blocked_account_id)
);

COMMENT ON TABLE vibetype.account_block IS E'@omit update\nBlocking of one account by another.';
COMMENT ON COLUMN vibetype.account_block.id IS E'@omit create\nThe account block''s internal id.';
COMMENT ON COLUMN vibetype.account_block.blocked_account_id IS 'The account id of the user who is blocked.';
COMMENT ON COLUMN vibetype.account_block.created_at IS E'@omit create\nTimestamp of when the account block was created.';
COMMENT ON COLUMN vibetype.account_block.created_by IS 'The account id of the user who created the account block.';

GRANT INSERT, SELECT ON TABLE vibetype.account_block TO vibetype_account;
GRANT SELECT ON TABLE vibetype.account_block TO vibetype_anonymous;

ALTER TABLE vibetype.account_block ENABLE ROW LEVEL SECURITY;

CREATE POLICY account_block_all ON vibetype.account_block FOR ALL
USING (
  created_by = vibetype.invoker_account_id()
);

COMMIT;
