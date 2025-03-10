BEGIN;

CREATE TABLE vibetype_private.jwt (
  id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  token    vibetype.jwt NOT NULL UNIQUE
);

COMMENT ON TABLE vibetype_private.jwt IS 'A list of tokens.';
COMMENT ON COLUMN vibetype_private.jwt.id IS 'The token''s id.';
COMMENT ON COLUMN vibetype_private.jwt.token IS 'The token.';

COMMIT;
