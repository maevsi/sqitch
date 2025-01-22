BEGIN;

CREATE TABLE maevsi.account (
  id        UUID PRIMARY KEY REFERENCES maevsi_private.account(id) ON DELETE CASCADE,

  username  TEXT NOT NULL CHECK (char_length(username) < 100 AND username ~ '^[-A-Za-z0-9]+$') UNIQUE
);

COMMENT ON TABLE maevsi.account IS 'Public account data.';
COMMENT ON COLUMN maevsi.account.id IS 'The account''s internal id.';
COMMENT ON COLUMN maevsi.account.username IS 'The account''s username.';

GRANT SELECT ON TABLE maevsi.account TO maevsi_account, maevsi_anonymous;

ALTER TABLE maevsi.account ENABLE ROW LEVEL SECURITY;

-- Make all accounts accessible by everyone.
CREATE POLICY account_select ON maevsi.account FOR SELECT USING (
  TRUE
);

COMMIT;
