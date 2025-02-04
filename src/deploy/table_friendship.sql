BEGIN;

CREATE TABLE maevsi.friendship (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  a_account_id        UUID NOT NULL REFERENCES maevsi.account(id),
  b_account_id        UUID NOT NULL REFERENCES maevsi.account(id),
  status              maevsi.friendship_status NOT NULL DEFAULT 'pending'::maevsi.friendship_status,

  created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_by          UUID NOT NULL REFERENCES maevsi.account(id),
  updated_at          TIMESTAMP WITH TIME ZONE,
  updated_by          UUID REFERENCES maevsi.account(id),

  UNIQUE (a_account_id, b_account_id),
  CHECK (a_account_id < b_account_id),
  CHECK (created_by <> updated_by),
  CHECK (created_by = a_account_id or created_by = b_account_id),
  CHECK (updated_by = a_account_id or updated_by = b_account_id)
);

COMMENT ON TABLE maevsi.friendship IS 'A friend relation together with its status.';
COMMENT ON COLUMN maevsi.friendship.id IS E'@omit create,update\nThe friend relation''s internal id.';
COMMENT ON COLUMN maevsi.friendship.a_account_id IS E'@omit update\nThe ''left'' side of the friend relation.';
COMMENT ON COLUMN maevsi.friendship.b_account_id IS E'@omit update\nThe ''right'' side of the friend relation.';
COMMENT ON COLUMN maevsi.friendship.status IS E'@omit create\nThe status of the friend relation.';
COMMENT ON COLUMN maevsi.friendship.created_at IS E'@omit create,update\nThe timestamp when the friend relation was created.';
COMMENT ON COLUMN maevsi.friendship.created_by IS E'@omit update\nThe account that created the friend relation was created.';
COMMENT ON COLUMN maevsi.friendship.updated_at IS E'@omit create\nThe timestamp when the friend relation''s status was updated.';
COMMENT ON COLUMN maevsi.friendship.updated_by IS E'@omit create\nThe account that updated the friend relation''s status.';

COMMIT;
