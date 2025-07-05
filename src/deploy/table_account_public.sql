BEGIN;

CREATE TABLE vibetype.account (
  id          UUID PRIMARY KEY REFERENCES vibetype_private.account(id) ON DELETE CASCADE,

  description TEXT CHECK (char_length(description) < 1000),
  imprint     TEXT CHECK (char_length(imprint) < 10000),
  username    TEXT NOT NULL CHECK (char_length(username) < 100 AND username ~ '^[-A-Za-z0-9]+$') UNIQUE
);

COMMENT ON TABLE vibetype.account IS E'@omit create,delete\nPublic account data.';
COMMENT ON COLUMN vibetype.account.id IS E'@omit create,update\nThe account''s internal id.';
COMMENT ON COLUMN vibetype.account.description IS 'The account''s description.';
COMMENT ON COLUMN vibetype.account.imprint IS 'The account''s imprint.';
COMMENT ON COLUMN vibetype.account.username IS E'@omit update\nThe account''s username.';

COMMIT;
