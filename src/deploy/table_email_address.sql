BEGIN;

\set role_service_grafana_username `cat /run/secrets/postgres-role-service-grafana-username`
\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

CREATE TYPE vibetype_private.email_status AS ENUM ('active', 'bounced', 'complained', 'unsubscribed');

CREATE TABLE vibetype_private.email_address (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id    UUID NOT NULL REFERENCES vibetype_private.subject(id),

  address       TEXT NOT NULL UNIQUE CHECK (char_length(address) <= 254),
  address_hash  TEXT GENERATED ALWAYS AS (md5(lower(substring(address, '\S(?:.*\S)*')))) STORED,
  status        vibetype_private.email_status NOT NULL DEFAULT 'active',
  status_reason TEXT CHECK (status_reason IS NULL OR char_length(status_reason) <= 512),

  created_at    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP WITH TIME ZONE,
  updated_by    UUID REFERENCES vibetype.account(id) ON DELETE SET NULL
);

CREATE INDEX idx_email_address_subject_id ON vibetype_private.email_address USING btree (subject_id);
CREATE INDEX idx_email_address_address_hash ON vibetype_private.email_address USING btree (address_hash);
CREATE INDEX idx_email_address_updated_by ON vibetype_private.email_address USING btree (updated_by);

COMMENT ON TYPE vibetype_private.email_status IS 'Email deliverability statuses: active, bounced, complained, or unsubscribed.';
COMMENT ON TABLE vibetype_private.email_address IS 'The canonical entity for an email address and its lifecycle state: deliverability status, and (via account_email_address/email_address_verification) verification. Every reference to an email address elsewhere in the schema goes through this table.';
COMMENT ON COLUMN vibetype_private.email_address.id IS 'The email address''s internal id.';
COMMENT ON COLUMN vibetype_private.email_address.subject_id IS 'The real-world person this address belongs to. Shared across every email address the same person has used, so a single subject key destruction erases outbox data for all of them at once.';
COMMENT ON COLUMN vibetype_private.email_address.address IS 'The email address. Must not exceed 254 characters (RFC 5321).';
COMMENT ON COLUMN vibetype_private.email_address.address_hash IS 'Hash of the address, generated using md5 on the lowercased trimmed version. Useful for case-insensitive lookups and to display a profile picture from Gravatar.';
COMMENT ON COLUMN vibetype_private.email_address.status IS 'The deliverability status: active (no issue), bounced (hard/permanent bounce reported by SES), complained (spam complaint reported by SES), or unsubscribed (explicit user opt-out).';
COMMENT ON COLUMN vibetype_private.email_address.status_reason IS 'Optional human-readable reason (e.g. bounce subtype or complaint feedback type). At most 512 characters.';
COMMENT ON COLUMN vibetype_private.email_address.created_at IS 'Timestamp when this address was first recorded.';
COMMENT ON COLUMN vibetype_private.email_address.updated_at IS 'Timestamp when this address''s status was last updated.';
COMMENT ON COLUMN vibetype_private.email_address.updated_by IS 'Account that last updated this address''s status, or NULL for service-triggered updates.';

ALTER TABLE vibetype_private.email_address ENABLE ROW LEVEL SECURITY;

GRANT SELECT ON TABLE vibetype_private.email_address TO :role_service_grafana_username;
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
