BEGIN;

DROP POLICY device_existing ON maevsi.device;
DROP POLICY device_new ON maevsi.device;

COMMIT;
