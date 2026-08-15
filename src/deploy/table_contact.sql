BEGIN;

-- TODO: consider moving this table to the `vibetype_private` schema, since it holds PII about
-- individuals (name, email, phone number, ...) who may not be platform users and never consented
-- to being on the platform, unlike the account holder who created the entry.
CREATE TABLE vibetype.contact (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  account_id            UUID REFERENCES vibetype.account(id) ON DELETE SET NULL,
  address_id            UUID REFERENCES vibetype.address(id) ON DELETE SET NULL,
  first_name            TEXT CHECK (char_length(first_name) > 0 AND char_length(first_name) <= 100),
  language              vibetype.language,
  last_name             TEXT CHECK (char_length(last_name) > 0 AND char_length(last_name) <= 100),
  nickname              TEXT CHECK (char_length(nickname) > 0 AND char_length(nickname) <= 100),
  note                  TEXT CHECK (char_length(note) > 0 AND char_length(note) <= 1000),
  phone_number          TEXT CHECK (phone_number ~ '^\+(?:[0-9] ?){6,14}[0-9]$'), -- E.164 format (https://wikipedia.org/wiki/E.164)
  time_zone             TEXT, -- validated via trigger
  url                   TEXT CHECK (char_length("url") <= 2000 AND "url" ~ '^https://[^[:space:]]+$'),

  created_at            TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by            UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,

  UNIQUE (created_by, account_id)
);

CREATE INDEX idx_contact_account_id ON vibetype.contact USING btree (account_id);
CREATE INDEX idx_contact_address_id ON vibetype.contact USING btree (address_id);
CREATE INDEX idx_contact_created_by ON vibetype.contact USING btree (created_by);
CREATE INDEX idx_contact_name_first ON vibetype.contact USING btree (first_name);
CREATE INDEX idx_contact_name_last ON vibetype.contact USING btree (last_name);

COMMENT ON TABLE vibetype.contact IS 'Stores contact information related to accounts, including personal details, communication preferences, and metadata.';
COMMENT ON COLUMN vibetype.contact.id IS E'@behavior -insert -update\nPrimary key, uniquely identifies each contact.';
COMMENT ON COLUMN vibetype.contact.account_id IS 'Optional reference to an associated account.';
COMMENT ON COLUMN vibetype.contact.address_id IS 'Optional reference to the physical address of the contact.';
COMMENT ON COLUMN vibetype.contact.first_name IS 'First name of the contact. Must be between 1 and 100 characters.';
COMMENT ON COLUMN vibetype.contact.language IS 'Reference to the preferred language of the contact.';
COMMENT ON COLUMN vibetype.contact.last_name IS 'Last name of the contact. Must be between 1 and 100 characters.';
COMMENT ON COLUMN vibetype.contact.nickname IS 'Nickname of the contact. Must be between 1 and 100 characters. Useful when the contact is not commonly referred to by their legal name.';
COMMENT ON COLUMN vibetype.contact.note IS 'Additional notes about the contact. Must be between 1 and 1,000 characters. Useful for providing context or distinguishing details if the name alone is insufficient.';
COMMENT ON COLUMN vibetype.contact.phone_number IS 'The international phone number of the contact, formatted according to E.164 (https://wikipedia.org/wiki/E.164).';
COMMENT ON COLUMN vibetype.contact.time_zone IS 'Time zone of the contact in IANA format, e.g., `Europe/Berlin` or `America/New_York`.';
COMMENT ON COLUMN vibetype.contact.url IS 'URL associated with the contact, must start with "https://" and not exceed 2,000 characters.';
COMMENT ON COLUMN vibetype.contact.created_at IS E'@behavior -insert -update\nTimestamp when the contact was created. Defaults to the current timestamp.';
COMMENT ON COLUMN vibetype.contact.created_by IS 'Reference to the account that created this contact. Enforces cascading deletion.';
COMMENT ON CONSTRAINT contact_created_by_account_id_key ON vibetype.contact IS 'Ensures the uniqueness of the combination of `created_by` and `account_id` for a contact.';

-- GRANTs, RLS and POLICYs are specified in `table_contact_policy`.

-- Email addresses now live in the contact_email_address join table (table_contact_email_address),
-- so the old `contact_identity_check` column CHECK became a constraint trigger: it must look up a
-- separate table instead of comparing columns on the same row. Deferred to the end of the
-- transaction so a contact and its first contact_email_address row can be inserted in either
-- order within the same statement/transaction.
--
-- The check itself is a plain function taking a contact id, not a trigger function, since it's
-- fired from two different tables (this one, and contact_email_address on DELETE) whose row types
-- don't share a common field name to read the contact id from.
CREATE FUNCTION vibetype.contact_identity_check(contact_id uuid) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM vibetype.contact c
    WHERE c.id = contact_identity_check.contact_id
      AND (
        c.account_id IS NOT NULL
        OR EXISTS (SELECT 1 FROM vibetype.contact_email_address cea WHERE cea.contact_id = c.id)
      )
  ) THEN
    RAISE EXCEPTION 'A contact must be reachable via a linked account or at least one email address.' USING ERRCODE = 'check_violation';
  END IF;
END;
$$;

CREATE FUNCTION vibetype.trigger_contact_identity_check() RETURNS TRIGGER
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
BEGIN
  PERFORM vibetype.contact_identity_check(NEW.id);
  RETURN NULL;
END;
$$;
COMMENT ON FUNCTION vibetype.trigger_contact_identity_check() IS 'Ensures each contact is reachable via a linked account or at least one email address, to satisfy the GDPR duty to inform data subjects whose personal data is stored. Shared by triggers on both vibetype.contact and vibetype.contact_email_address.';

CREATE CONSTRAINT TRIGGER contact_identity_check
  AFTER INSERT OR UPDATE OF account_id ON vibetype.contact
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.trigger_contact_identity_check();

CREATE FUNCTION vibetype.trigger_contact_check_time_zone() RETURNS TRIGGER
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  BEGIN
    IF NEW.time_zone IS NOT NULL THEN
      IF NOT EXISTS (
        SELECT 1 FROM pg_catalog.pg_timezone_names WHERE name = NEW.time_zone
      ) THEN
        RAISE EXCEPTION 'Invalid time zone: %', NEW.time_zone;
      END IF;
    END IF;

    RETURN NEW;
  END;
$$;
COMMENT ON FUNCTION vibetype.trigger_contact_check_time_zone() IS 'Validates that the time zone provided in the contact is a valid IANA time zone.';
GRANT EXECUTE ON FUNCTION vibetype.trigger_contact_check_time_zone() TO vibetype_account;

CREATE TRIGGER time_zone
  BEFORE INSERT OR UPDATE OF time_zone
  ON vibetype.contact
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.trigger_contact_check_time_zone();


CREATE FUNCTION vibetype.trigger_contact_update_account_id() RETURNS TRIGGER
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  BEGIN
    IF (
      -- invoked without account id
      vibetype.invoker_account_id() IS NULL
      OR
      -- invoked with account id
      -- and
      (
        -- updating own account's contact
        OLD.account_id = vibetype.invoker_account_id()
        AND
        OLD.created_by = vibetype.invoker_account_id()
        AND
        (
          -- trying to detach from account
          NEW.account_id IS DISTINCT FROM OLD.account_id
          OR
          NEW.created_by IS DISTINCT FROM OLD.created_by
        )
      )
    ) THEN
      RAISE 'You cannot remove the association of your account''s own contact with your account.' USING ERRCODE = 'foreign_key_violation';
    END IF;

    RETURN NEW;
  END;
$$;
COMMENT ON FUNCTION vibetype.trigger_contact_update_account_id() IS 'Prevents invalid updates to contacts.';
GRANT EXECUTE ON FUNCTION vibetype.trigger_contact_update_account_id() TO vibetype_account;

CREATE TRIGGER update_account_id
  BEFORE
    UPDATE OF account_id, created_by
  ON vibetype.contact
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.trigger_contact_update_account_id();

COMMIT;
