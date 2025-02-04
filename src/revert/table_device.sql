BEGIN;

-- DROP TRIGGER maevsi_trigger_device_update ON maevsi.device;
-- DROP INDEX maevsi.idx_device_updated_by;
DROP TABLE maevsi.device;

COMMIT;
