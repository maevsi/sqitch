BEGIN;

CREATE TABLE vibetype.account (
  id          UUID PRIMARY KEY REFERENCES vibetype_private.account(id) ON DELETE CASCADE,

  description TEXT CHECK (char_length(description) <= 1000),
  imprint_url TEXT CHECK (char_length(imprint_url) <= 2000 AND imprint_url ~ '^https://[^[:space:]]+$'),
  username    TEXT NOT NULL COLLATE unicode CHECK (char_length(username) <= 100 AND username ~ '^[-A-Za-z0-9]+$') UNIQUE
);

COMMENT ON TABLE vibetype.account IS E'@omit create,delete\nPublic account data.';
COMMENT ON COLUMN vibetype.account.id IS E'@omit create,update\nThe account''s internal id.';
COMMENT ON COLUMN vibetype.account.description IS 'The account''s description. Must not exceed 1,000 characters.';
COMMENT ON COLUMN vibetype.account.imprint_url IS 'The account''s imprint URL. Must start with "https://" and not exceed 2,000 characters.';
COMMENT ON COLUMN vibetype.account.username IS E'@omit update\nThe account''s username. Must be alphanumeric with hyphens and not exceed 100 characters.';

CREATE INDEX idx_account_username_like ON vibetype.account USING gin(username gin_trgm_ops);
COMMENT ON INDEX vibetype.idx_account_username_like IS 'Index useful for trigram matching as in LIKE/ILIKE conditions on username.';

COMMIT;
