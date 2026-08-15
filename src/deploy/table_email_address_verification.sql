BEGIN;

\set role_service_grafana_username `cat /run/secrets/postgres-role-service-grafana-username`

CREATE TABLE vibetype_private.email_address_verification (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email_address_id  UUID NOT NULL REFERENCES vibetype_private.email_address(id) ON DELETE CASCADE,

  code              UUID NOT NULL DEFAULT gen_random_uuid(),
  valid_until       TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT (CURRENT_TIMESTAMP + INTERVAL '1 day'),
  confirmed_at      TIMESTAMP WITH TIME ZONE,
  language          TEXT NOT NULL,
  time_zone         TEXT NOT NULL,

  created_at        TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_email_address_verification_email_address_id ON vibetype_private.email_address_verification USING btree (email_address_id);
CREATE UNIQUE INDEX idx_email_address_verification_code ON vibetype_private.email_address_verification USING btree (code);

COMMENT ON TABLE vibetype_private.email_address_verification IS 'A pending or confirmed proof-of-ownership challenge for an email address. Purpose-agnostic: used to confirm an address before registration completes today, and reusable unchanged for a future "add another email to my account" flow.';
COMMENT ON COLUMN vibetype_private.email_address_verification.id IS 'The verification''s internal id, referenced by whichever flow consumes a confirmed verification.';
COMMENT ON COLUMN vibetype_private.email_address_verification.email_address_id IS 'The email address being verified.';
COMMENT ON COLUMN vibetype_private.email_address_verification.code IS 'The UUID sent to the address owner to prove control of the inbox.';
COMMENT ON COLUMN vibetype_private.email_address_verification.valid_until IS 'The timestamp until which the code can be confirmed.';
COMMENT ON COLUMN vibetype_private.email_address_verification.confirmed_at IS 'Timestamp at which the code was confirmed, or null if still pending.';
COMMENT ON COLUMN vibetype_private.email_address_verification.language IS 'The locale requested at verification time, carried forward for whichever flow consumes this verification (e.g. an account registration welcome email), since it is not re-collected later.';
COMMENT ON COLUMN vibetype_private.email_address_verification.time_zone IS 'The time zone requested at verification time, carried forward the same way as language.';
COMMENT ON COLUMN vibetype_private.email_address_verification.created_at IS 'Timestamp at which this verification was requested.';

GRANT SELECT ON TABLE vibetype_private.email_address_verification TO :role_service_grafana_username;

COMMIT;
