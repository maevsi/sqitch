BEGIN;

\set role_service_grafana_username `cat /run/secrets/postgres-role-service-grafana-username`

CREATE TABLE vibetype_private.account_email_address (
  account_id               UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,
  email_address_id         UUID NOT NULL REFERENCES vibetype_private.email_address(id) ON DELETE CASCADE,

  is_primary               BOOLEAN NOT NULL DEFAULT TRUE,
  verification              UUID DEFAULT gen_random_uuid(),
  verification_valid_until  TIMESTAMP WITH TIME ZONE,

  created_at                TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (account_id, email_address_id),
  UNIQUE (email_address_id) -- an email address can only ever be claimed by one account, even though an account may claim several
);

CREATE UNIQUE INDEX idx_account_email_address_primary ON vibetype_private.account_email_address USING btree (account_id) WHERE is_primary;

COMMENT ON TABLE vibetype_private.account_email_address IS 'Links an account to an email address it claims. Verification lives here, not on email_address, since it proves this account''s claim on the address rather than being a property of the address itself. Modeled as a many-to-many join so a future "add a second email" feature is additive; today, exactly one is_primary row exists per account.';
COMMENT ON COLUMN vibetype_private.account_email_address.account_id IS 'The claiming account''s id.';
COMMENT ON COLUMN vibetype_private.account_email_address.email_address_id IS 'The claimed email address''s id.';
COMMENT ON COLUMN vibetype_private.account_email_address.is_primary IS 'Whether this is the account''s primary email address. At most one primary address per account.';
COMMENT ON COLUMN vibetype_private.account_email_address.verification IS 'The UUID used to verify this account''s claim on the address, or null if already verified.';
COMMENT ON COLUMN vibetype_private.account_email_address.verification_valid_until IS 'The timestamp until which this verification is valid.';
COMMENT ON COLUMN vibetype_private.account_email_address.created_at IS 'Timestamp at which this address was linked to the account.';
COMMENT ON INDEX vibetype_private.idx_account_email_address_primary IS 'Ensures at most one primary email address per account.';

CREATE FUNCTION vibetype_private.trigger_account_email_address_verification_valid_until() RETURNS TRIGGER
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  BEGIN
    IF (NEW.verification IS NULL) THEN
      NEW.verification_valid_until = NULL;
    ELSE
      IF ((OLD IS NULL) OR (OLD.verification IS DISTINCT FROM NEW.verification)) THEN
        NEW.verification_valid_until = (SELECT (CURRENT_TIMESTAMP + INTERVAL '1 day')::TIMESTAMP WITH TIME ZONE);
      END IF;
    END IF;

    RETURN NEW;
  END;
$$;
COMMENT ON FUNCTION vibetype_private.trigger_account_email_address_verification_valid_until() IS 'Sets the valid until column of the verification to its default value.';

CREATE TRIGGER verification
  BEFORE
       INSERT
    OR UPDATE OF verification
  ON vibetype_private.account_email_address
  FOR EACH ROW
  EXECUTE FUNCTION vibetype_private.trigger_account_email_address_verification_valid_until();

GRANT SELECT ON TABLE vibetype_private.account_email_address TO :role_service_grafana_username;

COMMIT;
