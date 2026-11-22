BEGIN;

CREATE TYPE vibetype.device_platform AS ENUM (
  'android',
  'ios',
  'web'
);

COMMENT ON TYPE vibetype.device_platform IS 'Platforms a push registration is made on: android, ios, web.';

COMMIT;
