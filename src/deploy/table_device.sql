BEGIN;

CREATE TABLE maevsi.device (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  fcm_token   TEXT CHECK (char_length("fcm_token") > 0 AND char_length("fcm_token") < 300),

  created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by  UUID REFERENCES maevsi.account(id) NOT NULL DEFAULT maevsi.invoker_account_id(),
  updated_at  TIMESTAMP WITH TIME ZONE,
  updated_by  UUID REFERENCES maevsi.account(id) NOT NULL,

  UNIQUE (created_by, fcm_token)
);

CREATE INDEX idx_device_updated_by ON maevsi.device USING btree (updated_by);

COMMENT ON TABLE maevsi.device IS E'@omit read,update\nA device that''s assigned to an account.';
COMMENT ON COLUMN maevsi.device.id IS E'@omit create,update\nThe internal id of the device.';
COMMENT ON COLUMN maevsi.device.fcm_token IS 'The Firebase Cloud Messaging token of the device that''s used to deliver notifications.';
COMMENT ON COLUMN maevsi.device.created_at IS E'@omit create,update\nTimestamp when the device was created. Defaults to the current timestamp.';
COMMENT ON COLUMN maevsi.device.created_by IS E'@omit create,update\nReference to the account that created the device.';
COMMENT ON COLUMN maevsi.device.updated_at IS E'@omit create,update\nTimestamp when the device was last updated.';
COMMENT ON COLUMN maevsi.device.updated_by IS E'@omit create,update\nReference to the account that last updated the device.';
COMMENT ON INDEX maevsi.idx_device_updated_by IS 'B-Tree index to optimize lookups by updater.';

-- GRANTs, RLS and POLICYs are specified in `table_contact_policy`.

CREATE TRIGGER maevsi_trigger_device_update
  BEFORE
    UPDATE
  ON maevsi.device
  FOR EACH ROW
  EXECUTE PROCEDURE maevsi.trigger_metadata_update();

COMMIT;
