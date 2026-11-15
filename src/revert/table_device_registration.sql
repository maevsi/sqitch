BEGIN;

DROP POLICY device_delete ON vibetype.device;
DROP POLICY device_select ON vibetype.device;

GRANT INSERT, UPDATE ON TABLE vibetype.device TO vibetype_account;

DROP INDEX vibetype.idx_device_last_seen_at;
DROP INDEX vibetype.idx_device_created_by;

ALTER TABLE vibetype.device
  DROP CONSTRAINT device_fcm_token_key,
  DROP COLUMN label,
  DROP COLUMN last_seen_at,
  DROP COLUMN platform,
  ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE,
  ADD COLUMN updated_by UUID REFERENCES vibetype.account(id) ON DELETE SET NULL,
  ADD CONSTRAINT device_created_by_fcm_token_key UNIQUE (created_by, fcm_token);

CREATE INDEX idx_device_updated_by ON vibetype.device USING btree (updated_by);

COMMENT ON TABLE vibetype.device IS E'A device that''s assigned to an account.';
COMMENT ON COLUMN vibetype.device.created_by IS E'@behavior -update\nReference to the account that created the device.';
COMMENT ON COLUMN vibetype.device.fcm_token IS 'The Firebase Cloud Messaging token of the device that''s used to deliver notifications. Must be non-empty and not exceed 300 characters.';
COMMENT ON COLUMN vibetype.device.updated_at IS E'@behavior -insert -update\nTimestamp when the device was last updated.';
COMMENT ON COLUMN vibetype.device.updated_by IS E'@behavior -insert -update\nReference to the account that last updated the device.';
COMMENT ON INDEX vibetype.idx_device_updated_by IS 'B-Tree index to optimize lookups by updater.';

CREATE TRIGGER update
  BEFORE
    UPDATE
  ON vibetype.device
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.trigger_metadata_update();

CREATE FUNCTION vibetype.trigger_device_update_fcm_token() RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.fcm_token IS DISTINCT FROM OLD.fcm_token THEN
    RAISE EXCEPTION 'When updating a device, the FCM token''s value must stay the same. The update only updates the `updated_at` and `updated_by` metadata columns. If you want to update the FCM token for the device, recreate the device with a new FCM token.'
      USING ERRCODE = 'integrity_constraint_violation';
  END IF;
  RETURN NEW;
END;
$$;
COMMENT ON FUNCTION vibetype.trigger_device_update_fcm_token() IS 'Trigger function to ensure that only the metadata fields `updated_at` and `updated_by` are updated when a device row is modified. Raises an exception if the `fcm_token` value is changed.';
GRANT EXECUTE ON FUNCTION vibetype.trigger_device_update_fcm_token() TO vibetype_account;

CREATE TRIGGER update_fcm
  BEFORE
    UPDATE
  ON vibetype.device
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.trigger_device_update_fcm_token();

CREATE POLICY device_all ON vibetype.device FOR ALL
USING (
  created_by = vibetype.invoker_account_id()
);

COMMIT;
