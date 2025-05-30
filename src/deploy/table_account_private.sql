BEGIN;

\set role_service_grafana_username `cat /run/secrets/postgres_role_service_grafana_username`

CREATE TABLE vibetype_private.account (
  id                                         UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  birth_date                                 DATE, -- TODO: evaluate if this should be `NOT NULL` for all new accounts
  email_address                              TEXT NOT NULL CHECK (char_length(email_address) < 255) UNIQUE, -- no regex check as "a valid email address is one that you can send emails to" (http://www.dominicsayers.com/isemail/)
  email_address_verification                 UUID DEFAULT gen_random_uuid(),
  email_address_verification_valid_until     TIMESTAMP WITH TIME ZONE,
  location                                   GEOGRAPHY(Point, 4326),
  password_hash                              TEXT NOT NULL,
  password_reset_verification                UUID,
  password_reset_verification_valid_until    TIMESTAMP WITH TIME ZONE,
  upload_quota_bytes                         BIGINT NOT NULL DEFAULT 10485760, -- 10 mebibyte

  created_at                                 TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_activity                              TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_account_private_location ON vibetype_private.account USING gist (location);

COMMENT ON TABLE vibetype_private.account IS 'Private account data.';
COMMENT ON COLUMN vibetype_private.account.id IS 'The account''s internal id.';
COMMENT ON COLUMN vibetype_private.account.birth_date IS 'The account owner''s date of birth.';
COMMENT ON COLUMN vibetype_private.account.email_address IS 'The account''s email address for account related information.';
COMMENT ON COLUMN vibetype_private.account.email_address_verification IS 'The UUID used to verify an email address, or null if already verified.';
COMMENT ON COLUMN vibetype_private.account.email_address_verification_valid_until IS 'The timestamp until which an email address verification is valid.';
COMMENT ON COLUMN vibetype_private.account.location IS 'The account''s geometric location.';
COMMENT ON COLUMN vibetype_private.account.password_hash IS 'The account''s password, hashed and salted.';
COMMENT ON COLUMN vibetype_private.account.password_reset_verification IS 'The UUID used to reset a password, or null if there is no pending reset request.';
COMMENT ON COLUMN vibetype_private.account.password_reset_verification_valid_until IS 'The timestamp until which a password reset is valid.';
COMMENT ON COLUMN vibetype_private.account.upload_quota_bytes IS 'The account''s upload quota in bytes.';
COMMENT ON COLUMN vibetype_private.account.created_at IS 'Timestamp at which the account was last active.';
COMMENT ON COLUMN vibetype_private.account.last_activity IS 'Timestamp at which the account last requested an access token.';
COMMENT ON INDEX vibetype_private.idx_account_private_location IS 'GIST index on the location for efficient spatial queries.';

CREATE FUNCTION vibetype_private.account_email_address_verification_valid_until() RETURNS TRIGGER AS $$
  BEGIN
    IF (NEW.email_address_verification IS NULL) THEN
      NEW.email_address_verification_valid_until = NULL;
    ELSE
      IF ((OLD IS NULL) OR (OLD.email_address_verification IS DISTINCT FROM NEW.email_address_verification)) THEN
        NEW.email_address_verification_valid_until = (SELECT (CURRENT_TIMESTAMP + INTERVAL '1 day')::TIMESTAMP WITH TIME ZONE);
      END IF;
    END IF;

    RETURN NEW;
  END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.account_email_address_verification_valid_until() IS 'Sets the valid until column of the email address verification to it''s default value.';

GRANT EXECUTE ON FUNCTION vibetype_private.account_email_address_verification_valid_until() TO vibetype_account;

CREATE FUNCTION vibetype_private.account_password_reset_verification_valid_until() RETURNS TRIGGER AS $$
  BEGIN
    IF (NEW.password_reset_verification IS NULL) THEN
      NEW.password_reset_verification_valid_until = NULL;
    ELSE
      IF ((OLD IS NULL) OR (OLD.password_reset_verification IS DISTINCT FROM NEW.password_reset_verification)) THEN
        NEW.password_reset_verification_valid_until = (SELECT (CURRENT_TIMESTAMP + INTERVAL '2 hours')::TIMESTAMP WITH TIME ZONE);
      END IF;
    END IF;

    RETURN NEW;
  END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.account_password_reset_verification_valid_until() IS 'Sets the valid until column of the email address verification to it''s default value.';

GRANT EXECUTE ON FUNCTION vibetype_private.account_password_reset_verification_valid_until() TO vibetype_account;

CREATE TRIGGER vibetype_private_account_email_address_verification_valid_until
  BEFORE
       INSERT
    OR UPDATE OF email_address_verification
  ON vibetype_private.account
  FOR EACH ROW
  EXECUTE PROCEDURE vibetype_private.account_email_address_verification_valid_until();

CREATE TRIGGER vibetype_private_account_password_reset_verification_valid_until
  BEFORE
       INSERT
    OR UPDATE OF password_reset_verification
  ON vibetype_private.account
  FOR EACH ROW
  EXECUTE PROCEDURE vibetype_private.account_password_reset_verification_valid_until();

GRANT SELECT ON TABLE vibetype_private.account TO :role_service_grafana_username;

COMMIT;
