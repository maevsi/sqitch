BEGIN;

DROP TRIGGER vibetype_trigger_device_update_fcm ON vibetype.device;
DROP FUNCTION vibetype.trigger_metadata_update_fcm;
DROP TRIGGER vibetype_trigger_device_update ON vibetype.device;
DROP INDEX vibetype.idx_device_updated_by;

DROP POLICY device_all ON vibetype.device;

DROP TABLE vibetype.device;

COMMIT;
