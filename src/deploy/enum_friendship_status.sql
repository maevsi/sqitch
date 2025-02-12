BEGIN;

CREATE TYPE maevsi.friendship_status AS ENUM (
  'accepted',
  'pending'
);

COMMENT ON TYPE maevsi.friendship_status IS 'Possible status values of a friend relation.
There is not status ''rejected'' because friendship records will be deleted as soon as a friendship is rejected.';

COMMIT;
