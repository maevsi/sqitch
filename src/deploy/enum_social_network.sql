-- Deploy maevsi:enum_social_network to pg
-- requires: schema_public

BEGIN;

CREATE TYPE maevsi.social_network AS ENUM (
  'facebook',
  'instagram',
  'tiktok',
  'x'
);

COMMENT ON TYPE maevsi.social_network IS 'Social networks.';

COMMIT;
