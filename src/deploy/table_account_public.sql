BEGIN;

CREATE TABLE vibetype.account (
  id          UUID PRIMARY KEY REFERENCES vibetype_private.account(id) ON DELETE CASCADE,

  description TEXT CHECK (char_length(description) < 1000),
  imprint     TEXT CHECK (char_length(imprint) < 10000),
  username    TEXT NOT NULL CHECK (char_length(username) < 100 AND username ~ '^[-A-Za-z0-9]+$') UNIQUE
);

COMMENT ON TABLE vibetype.account IS 'Public account data.';
COMMENT ON COLUMN vibetype.account.id IS 'The account''s internal id.';
COMMENT ON COLUMN vibetype.account.description IS 'The account''s description.';
COMMENT ON COLUMN vibetype.account.imprint IS 'The account''s imprint.';
COMMENT ON COLUMN vibetype.account.username IS 'The account''s username.';

GRANT SELECT ON TABLE vibetype.account TO vibetype_account, vibetype_anonymous;

ALTER TABLE vibetype.account ENABLE ROW LEVEL SECURITY;

-- Make all accounts accessible by everyone.
CREATE POLICY account_select ON vibetype.account FOR SELECT USING (
  TRUE
);

COMMIT;
