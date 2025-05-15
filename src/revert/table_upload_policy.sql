BEGIN;

DROP POLICY upload_delete ON vibetype.upload;
DROP POLICY upload_select ON vibetype.upload;
DROP POLICY upload_insert ON vibetype.upload;
DROP TRIGGER vibetype_trigger_upload_insert ON vibetype.upload;
DROP FUNCTION vibetype.trigger_upload_insert();
DROP POLICY upload_service_vibetype_all ON vibetype.upload;

COMMIT;
