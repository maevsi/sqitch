-- Deploy maevsi:table_social_network to pg
-- requires: schema_public

BEGIN;

CREATE TABLE maevsi.social_network (
  name TEXT PRIMARY KEY
);

COMMENT ON TABLE maevsi.social_network IS 'Social networks.';
COMMENT ON COLUMN maevsi.social_network.name IS 'A social network name.';

INSERT INTO maevsi.social_network (name)
VALUES
  ('Instagram'),
  ('TikTok'),
  ('Facebook'),
  ('X');

COMMIT;
