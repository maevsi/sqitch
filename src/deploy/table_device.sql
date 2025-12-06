BEGIN;

CREATE TABLE vibetype.device (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  fcm_token   TEXT NOT NULL CHECK (char_length("fcm_token") > 0 AND char_length("fcm_token") < 300),

  created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by  UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,
  updated_at  TIMESTAMP WITH TIME ZONE,
  updated_by  UUID REFERENCES vibetype.account(id) ON DELETE SET NULL,

  UNIQUE (created_by, fcm_token)
);

CREATE INDEX idx_device_updated_by ON vibetype.device USING btree (updated_by);

COMMENT ON TABLE vibetype.device IS E'A device that''s assigned to an account.';
COMMENT ON COLUMN vibetype.device.id IS E'@omit create,update\nThe internal id of the device.';
COMMENT ON COLUMN vibetype.device.fcm_token IS 'The Firebase Cloud Messaging token of the device that''s used to deliver notifications.';
COMMENT ON COLUMN vibetype.device.created_at IS E'@omit create,update\nTimestamp when the device was created. Defaults to the current timestamp.';
COMMENT ON COLUMN vibetype.device.created_by IS E'@omit update\nReference to the account that created the device.';
COMMENT ON COLUMN vibetype.device.updated_at IS E'@omit create,update\nTimestamp when the device was last updated.';
COMMENT ON COLUMN vibetype.device.updated_by IS E'@omit create,update\nReference to the account that last updated the device.';
COMMENT ON INDEX vibetype.idx_device_updated_by IS 'B-Tree index to optimize lookups by updater.';

-- GRANTs, RLS and POLICYs are specified in `table_contact_policy`.

CREATE TRIGGER vibetype_trigger_device_update
  BEFORE
    UPDATE
  ON vibetype.device
  FOR EACH ROW
  EXECUTE PROCEDURE vibetype.trigger_metadata_update();


CREATE FUNCTION vibetype.trigger_metadata_update_fcm()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.fcm_token IS DISTINCT FROM OLD.fcm_token THEN
    RAISE EXCEPTION 'When updating a device, the FCM token''s value must stay the same. The update only updates the `updated_at` and `updated_by` metadata columns. If you want to update the FCM token for the device, recreate the device with a new FCM token.'
      USING ERRCODE = 'integrity_constraint_violation';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER vibetype_trigger_device_update_fcm
  BEFORE
    UPDATE
  ON vibetype.device
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.trigger_metadata_update_fcm();

\set role_service_vibetype_username `cat /run/secrets/postgres_role_service_vibetype_username`

GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE vibetype.device TO vibetype_account;
GRANT SELECT ON TABLE vibetype.device TO :role_service_vibetype_username;

ALTER TABLE vibetype.device ENABLE ROW LEVEL SECURITY;

CREATE POLICY device_all ON vibetype.device FOR ALL
USING (
  created_by = vibetype.invoker_account_id()
);

CREATE POLICY device_service_vibetype_select ON vibetype.device FOR SELECT
TO :role_service_vibetype_username
USING (
  TRUE
);

COMMIT;
