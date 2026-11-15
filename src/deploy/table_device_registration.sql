BEGIN;

-- A token identifies one push registration, so it may exist only once.
-- Of duplicates across accounts the most recently active row survives.
DELETE FROM vibetype.device d
USING (
  SELECT id, row_number() OVER (PARTITION BY fcm_token ORDER BY COALESCE(updated_at, created_at) DESC, id DESC) AS position
  FROM vibetype.device
) ranked
WHERE d.id = ranked.id
  AND ranked.position > 1;

DROP POLICY device_all ON vibetype.device;

DROP TRIGGER update_fcm ON vibetype.device;
DROP FUNCTION vibetype.trigger_device_update_fcm_token();
DROP TRIGGER update ON vibetype.device;

DROP INDEX vibetype.idx_device_updated_by;

ALTER TABLE vibetype.device
  DROP CONSTRAINT device_created_by_fcm_token_key,
  DROP COLUMN updated_at,
  DROP COLUMN updated_by,
  ADD CONSTRAINT device_fcm_token_key UNIQUE (fcm_token),
  -- Rows that exist so far are web registrations or of unknown origin.
  ADD COLUMN label TEXT CHECK (char_length(label) BETWEEN 1 AND 100),
  ADD COLUMN last_seen_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN platform vibetype.device_platform NOT NULL DEFAULT 'web';

ALTER TABLE vibetype.device ALTER COLUMN platform DROP DEFAULT;

CREATE INDEX idx_device_created_by ON vibetype.device USING btree (created_by);
CREATE INDEX idx_device_last_seen_at ON vibetype.device USING btree (last_seen_at);

COMMENT ON TABLE vibetype.device IS E'@behavior -insert -update\nA push registration of an account, one per Firebase Cloud Messaging token. Rows are created by `device_register` only.';
COMMENT ON COLUMN vibetype.device.created_by IS E'@behavior -insert -update\nReference to the account that owns the registration.';
COMMENT ON COLUMN vibetype.device.fcm_token IS E'@behavior -insert -update\nThe Firebase Cloud Messaging token that is used to deliver notifications. Unique across all accounts.';
COMMENT ON COLUMN vibetype.device.label IS E'@behavior -insert -update\nA short human-readable name of the device, e.g. `Firefox on Linux`. `NULL` if unknown.';
COMMENT ON COLUMN vibetype.device.last_seen_at IS E'@behavior -insert -update\nThe timestamp when the registration was last refreshed. Registrations that are not refreshed for 90 days no longer receive notifications.';
COMMENT ON COLUMN vibetype.device.platform IS E'@behavior -insert -update\nThe platform the registration was made on.';
COMMENT ON INDEX vibetype.idx_device_created_by IS 'B-Tree index to optimize lookups by owner.';
COMMENT ON INDEX vibetype.idx_device_last_seen_at IS 'B-Tree index to optimize pruning of stale registrations.';

REVOKE INSERT, UPDATE ON TABLE vibetype.device FROM vibetype_account;

CREATE POLICY device_select ON vibetype.device FOR SELECT
USING (
  created_by = (SELECT vibetype.invoker_account_id())
);

CREATE POLICY device_delete ON vibetype.device FOR DELETE
USING (
  created_by = (SELECT vibetype.invoker_account_id())
);

COMMIT;
