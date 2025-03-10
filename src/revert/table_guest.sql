BEGIN;

DROP INDEX vibetype.idx_guest_updated_by;
DROP TABLE vibetype.guest;

COMMIT;
