BEGIN;

CREATE TABLE maevsi_private.jwt (
  id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  token    maevsi.jwt NOT NULL UNIQUE
);

COMMENT ON TABLE maevsi_private.jwt IS 'A list of tokens.';
COMMENT ON COLUMN maevsi_private.jwt.id IS 'The token''s id.';
COMMENT ON COLUMN maevsi_private.jwt.token IS 'The token.';

COMMIT;
