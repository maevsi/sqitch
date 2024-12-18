BEGIN;

CREATE TYPE maevsi.event_size AS ENUM (
  'small',
  'medium',
  'large',
  'huge'
);

COMMENT ON TYPE maevsi.event_size IS 'Possible event sizes: small, medium, large, huge.';

COMMIT;
