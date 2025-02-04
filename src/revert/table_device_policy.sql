BEGIN;

DROP POLICY device_delete ON maevsi.device;
DROP POLICY device_insert ON maevsi.device;

COMMIT;
