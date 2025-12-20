BEGIN;

DROP POLICY device_all ON vibetype.device;

DROP TRIGGER update_fcm ON vibetype.device;
DROP FUNCTION vibetype.trigger_device_update_fcm_token();
DROP TRIGGER update ON vibetype.device;

DROP INDEX vibetype.idx_device_updated_by;
DROP TABLE vibetype.device;

COMMIT;
