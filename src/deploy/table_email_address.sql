BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres_role_service_vibetype_username`

CREATE TYPE vibetype_private.email_address_status AS ENUM ('bounced', 'complained', 'unsubscribed');

CREATE TABLE vibetype_private.email_address (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  email_address  TEXT NOT NULL UNIQUE CHECK (char_length(email_address) <= 254),
  status         vibetype_private.email_address_status NOT NULL,
  reason         TEXT,

  created_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP WITH TIME ZONE,
  updated_by     UUID REFERENCES vibetype.account(id) ON DELETE SET NULL -- TODO: remove when metadata trigger is changed to optionally include this field
);

CREATE INDEX idx_email_address_updated_by ON vibetype_private.email_address USING btree (updated_by);

COMMENT ON TYPE vibetype_private.email_address_status IS 'Email deliverability statuses: bounced, complained, or unsubscribed.';
COMMENT ON TABLE vibetype_private.email_address IS 'Tracks email addresses with a deliverability issue: hard bounces, spam complaints, or explicit unsubscribes.';
COMMENT ON COLUMN vibetype_private.email_address.id IS 'Unique row identifier.';
COMMENT ON COLUMN vibetype_private.email_address.email_address IS 'The affected email address. At most 254 characters (RFC 5321).';
COMMENT ON COLUMN vibetype_private.email_address.status IS 'The deliverability status: bounced (hard/permanent bounce reported by SES), complained (spam complaint reported by SES), or unsubscribed (explicit user opt-out).';
COMMENT ON COLUMN vibetype_private.email_address.reason IS 'Optional human-readable reason (e.g. bounce subtype or complaint feedback type).';
COMMENT ON COLUMN vibetype_private.email_address.created_at IS 'Timestamp when this status was first recorded.';
COMMENT ON COLUMN vibetype_private.email_address.updated_at IS 'Timestamp when this status was last updated.';
COMMENT ON COLUMN vibetype_private.email_address.updated_by IS 'Account that last updated this row, or NULL for service-triggered updates.';
COMMENT ON INDEX vibetype_private.idx_email_address_updated_by IS 'Index on the updated_by column to optimize queries filtering by the account that last updated the email address status.';

ALTER TABLE vibetype_private.email_address ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT, UPDATE ON TABLE vibetype_private.email_address TO :role_service_vibetype_username;
GRANT USAGE ON SCHEMA vibetype_private TO :role_service_vibetype_username; -- TODO: move to schema in next major

CREATE POLICY email_address_service_vibetype_all ON vibetype_private.email_address
  FOR ALL
  TO :role_service_vibetype_username
  USING (TRUE);

CREATE TRIGGER update
  BEFORE UPDATE ON vibetype_private.email_address
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.trigger_metadata_update();

COMMIT;
