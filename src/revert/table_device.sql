BEGIN;

DROP TRIGGER maevsi_trigger_device_update_fcm ON maevsi.device;
DROP FUNCTION maevsi.trigger_metadata_update_fcm;
DROP TRIGGER maevsi_trigger_device_update ON maevsi.device;
DROP INDEX maevsi.idx_device_updated_by;
DROP TABLE maevsi.device;

COMMIT;
