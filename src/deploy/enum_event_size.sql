BEGIN;

CREATE TYPE vibetype.event_size AS ENUM (
  'small',
  'medium',
  'large',
  'huge'
);

COMMENT ON TYPE vibetype.event_size IS 'Possible event sizes: small, medium, large, huge.';

COMMIT;
