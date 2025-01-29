CREATE TABLE maevsi.friend (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  sender_account_id   UUID NOT NULL REFERENCES account(id),
  receiver_account_id UUID NOT NULL REFERENCES account(id),
  status              VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'blocked')), -- TODO: extract to enum

  created_at          TIMESTAMP WITH TIMEZONE DEFAULT NOW(),
  updated_at          TIMESTAMP WITH TIMEZONE,

  UNIQUE (sender_account_id, receiver_account_id),
  CHECK (sender_account_id <> receiver_account_id),
  CHECK (sender_account_id::TEXT < receiver_account_id::TEXT)
);
