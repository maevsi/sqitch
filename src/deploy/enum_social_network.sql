BEGIN;

CREATE TYPE vibetype.social_network AS ENUM (
  'facebook',
  'instagram',
  'tiktok',
  'x'
);

COMMENT ON TYPE vibetype.social_network IS 'Social networks.';

COMMIT;
