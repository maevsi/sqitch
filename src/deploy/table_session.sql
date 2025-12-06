BEGIN;

CREATE TABLE vibetype_private.session (
  id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  token    vibetype.session NOT NULL UNIQUE
);

COMMENT ON TABLE vibetype_private.session IS 'A list of tokens.';
COMMENT ON COLUMN vibetype_private.session.id IS 'The token''s id.';
COMMENT ON COLUMN vibetype_private.session.token IS 'The token.';

COMMIT;
