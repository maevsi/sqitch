BEGIN;

CREATE TABLE vibetype.contact (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  account_id            UUID REFERENCES vibetype.account(id) ON DELETE SET NULL,
  address_id            UUID REFERENCES vibetype.address(id) ON DELETE SET NULL,
  email_address         TEXT CHECK (char_length(email_address) <= 254), -- no regex check as "a valid email address is one that you can send emails to" (http://www.dominicsayers.com/isemail/)
  email_address_hash    TEXT GENERATED ALWAYS AS (md5(lower(substring(email_address, '\S(?:.*\S)*')))) STORED, -- for gravatar profile pictures
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

COMMENT ON TABLE vibetype.contact IS 'Stores contact information related to accounts, including personal details, communication preferences, and metadata.';
COMMENT ON COLUMN vibetype.contact.id IS E'@omit create,update\nPrimary key, uniquely identifies each contact.';
COMMENT ON COLUMN vibetype.contact.account_id IS 'Optional reference to an associated account.';
COMMENT ON COLUMN vibetype.contact.address_id IS 'Optional reference to the physical address of the contact.';
COMMENT ON COLUMN vibetype.contact.email_address IS 'Email address of the contact. Must not exceed 254 characters (RFC 5321).';
COMMENT ON COLUMN vibetype.contact.email_address_hash IS E'@omit create,update\nHash of the email address, generated using md5 on the lowercased trimmed version of the email. Useful to display a profile picture from Gravatar.';
COMMENT ON COLUMN vibetype.contact.first_name IS 'First name of the contact. Must be between 1 and 100 characters.';
COMMENT ON COLUMN vibetype.contact.language IS 'Reference to the preferred language of the contact.';
COMMENT ON COLUMN vibetype.contact.last_name IS 'Last name of the contact. Must be between 1 and 100 characters.';
COMMENT ON COLUMN vibetype.contact.nickname IS 'Nickname of the contact. Must be between 1 and 100 characters. Useful when the contact is not commonly referred to by their legal name.';
COMMENT ON COLUMN vibetype.contact.note IS 'Additional notes about the contact. Must be between 1 and 1,000 characters. Useful for providing context or distinguishing details if the name alone is insufficient.';
COMMENT ON COLUMN vibetype.contact.phone_number IS 'The international phone number of the contact, formatted according to E.164 (https://wikipedia.org/wiki/E.164).';
COMMENT ON COLUMN vibetype.contact.time_zone IS 'Time zone of the contact in IANA format, e.g., `Europe/Berlin` or `America/New_York`.';
COMMENT ON COLUMN vibetype.contact.url IS 'URL associated with the contact, must start with "https://" and not exceed 2,000 characters.';
COMMENT ON COLUMN vibetype.contact.created_at IS E'@omit create,update\nTimestamp when the contact was created. Defaults to the current timestamp.';
COMMENT ON COLUMN vibetype.contact.created_by IS 'Reference to the account that created this contact. Enforces cascading deletion.';
COMMENT ON CONSTRAINT contact_created_by_account_id_key ON vibetype.contact IS 'Ensures the uniqueness of the combination of `created_by` and `account_id` for a contact.';

-- GRANTs, RLS and POLICYs are specified in `table_contact_policy`.

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
