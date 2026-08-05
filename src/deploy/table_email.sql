BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

CREATE TYPE vibetype_private.email_status AS ENUM ('active', 'bounced', 'complained', 'unsubscribed'); -- TODO: add "unverified", migrating the existing logic for this here

CREATE TABLE vibetype_private.email (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  address      TEXT NOT NULL UNIQUE CHECK (char_length(address) <= 254),
  address_hash TEXT GENERATED ALWAYS AS (lower(address)) STORED,
  status       vibetype_private.email_status NOT NULL,
  reason       TEXT CHECK (reason IS NULL OR char_length(reason) <= 512),

  created_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP WITH TIME ZONE,
  updated_by     UUID REFERENCES vibetype.account(id) ON DELETE SET NULL -- TODO: remove when metadata trigger is changed to optionally include this field
);

CREATE INDEX idx_email_updated_by ON vibetype_private.email USING btree (updated_by);

COMMENT ON TYPE vibetype_private.email_status IS 'Email deliverability statuses: active, bounced, complained, or unsubscribed.';
COMMENT ON TABLE vibetype_private.email IS 'Tracks email addresses with a deliverability issue: hard bounces, spam complaints, or explicit unsubscribes.';
COMMENT ON COLUMN vibetype_private.email.id IS 'Unique row identifier.';
COMMENT ON COLUMN vibetype_private.email.address IS 'The affected email address. At most 254 characters (RFC 5321).';
COMMENT ON COLUMN vibetype_private.email.address_hash IS 'Lowercased version of the address, generated for case-insensitive lookups.';
COMMENT ON COLUMN vibetype_private.email.status IS 'The deliverability status: active (no issue), bounced (hard/permanent bounce reported by SES), complained (spam complaint reported by SES), or unsubscribed (explicit user opt-out).';
COMMENT ON COLUMN vibetype_private.email.reason IS 'Optional human-readable reason (e.g. bounce subtype or complaint feedback type). At most 512 characters.';
COMMENT ON COLUMN vibetype_private.email.created_at IS 'Timestamp when this status was first recorded.';
COMMENT ON COLUMN vibetype_private.email.updated_at IS 'Timestamp when this status was last updated.';
COMMENT ON COLUMN vibetype_private.email.updated_by IS 'Account that last updated this row, or NULL for service-triggered updates.';
COMMENT ON INDEX vibetype_private.idx_email_updated_by IS 'Index on the updated_by column to optimize queries filtering by the account that last updated the email address status.';

ALTER TABLE vibetype_private.email ENABLE ROW LEVEL SECURITY;

GRANT SELECT, INSERT, UPDATE ON TABLE vibetype_private.email TO :role_service_vibetype_username;
GRANT USAGE ON SCHEMA vibetype_private TO :role_service_vibetype_username; -- TODO: move to schema in next major

CREATE POLICY email_service_vibetype_all ON vibetype_private.email
  FOR ALL
  TO :role_service_vibetype_username
  USING (TRUE);

CREATE TRIGGER update
  BEFORE UPDATE ON vibetype_private.email
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.trigger_metadata_update();

COMMIT;
