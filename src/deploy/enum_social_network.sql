BEGIN;

CREATE TYPE maevsi.social_network AS ENUM (
  'facebook',
  'instagram',
  'tiktok',
  'x'
);

COMMENT ON TYPE maevsi.social_network IS 'Social networks.';

COMMIT;
