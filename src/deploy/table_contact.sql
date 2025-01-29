BEGIN;

CREATE TABLE maevsi.contact (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  account_id            UUID REFERENCES maevsi.account(id),
  address               TEXT CHECK (char_length("address") > 0 AND char_length("address") <= 300),
  author_account_id     UUID NOT NULL REFERENCES maevsi.account(id) ON DELETE CASCADE,
  email_address         TEXT CHECK (char_length(email_address) < 255), -- no regex check as "a valid email address is one that you can send emails to" (http://www.dominicsayers.com/isemail/)
  email_address_hash    TEXT GENERATED ALWAYS AS (md5(lower(substring(email_address, '\S(?:.*\S)*')))) STORED, -- for gravatar profile pictures
  first_name            TEXT CHECK (char_length(first_name) > 0 AND char_length(first_name) <= 100),
  language              maevsi.language,
  last_name             TEXT CHECK (char_length(last_name) > 0 AND char_length(last_name) <= 100),
  nickname              TEXT CHECK (char_length(nickname) > 0 AND char_length(nickname) <= 100),
  note                  TEXT CHECK (char_length(note) > 0 AND char_length(note) <= 1000),
  phone_number          TEXT CHECK (phone_number ~ '^\+(?:[0-9] ?){6,14}[0-9]$'), -- E.164 format (https://wikipedia.org/wiki/E.164)
  timezone              TEXT CHECK (timezone ~ '^([+-](0[0-9]|1[0-4]):[0-5][0-9]|Z)$'),
  url                   TEXT CHECK (char_length("url") <= 300 AND "url" ~ '^https:\/\/'),

  created_at            TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

  UNIQUE (author_account_id, account_id)
);

COMMENT ON TABLE maevsi.contact IS 'Stores contact information related to accounts, including personal details, communication preferences, and metadata.';
COMMENT ON COLUMN maevsi.contact.id IS E'@omit create,update\nPrimary key, uniquely identifies each contact.';
COMMENT ON COLUMN maevsi.contact.account_id IS 'Optional reference to an associated account.';
COMMENT ON COLUMN maevsi.contact.address IS 'Physical address of the contact. Must be between 1 and 300 characters.';
COMMENT ON COLUMN maevsi.contact.author_account_id IS 'Reference to the account that created this contact. Enforces cascading deletion.';
COMMENT ON COLUMN maevsi.contact.email_address IS 'Email address of the contact. Must be shorter than 256 characters.';
COMMENT ON COLUMN maevsi.contact.email_address_hash IS E'@omit create,update\nHash of the email address, generated using md5 on the lowercased trimmed version of the email. Useful to display a profile picture from Gravatar.';
COMMENT ON COLUMN maevsi.contact.first_name IS 'First name of the contact. Must be between 1 and 100 characters.';
COMMENT ON COLUMN maevsi.contact.language IS 'Reference to the preferred language of the contact.';
COMMENT ON COLUMN maevsi.contact.last_name IS 'Last name of the contact. Must be between 1 and 100 characters.';
COMMENT ON COLUMN maevsi.contact.nickname IS 'Nickname of the contact. Must be between 1 and 100 characters. Useful when the contact is not commonly referred to by their legal name.';
COMMENT ON COLUMN maevsi.contact.note IS 'Additional notes about the contact. Must be between 1 and 1.000 characters. Useful for providing context or distinguishing details if the name alone is insufficient.';
COMMENT ON COLUMN maevsi.contact.phone_number IS 'The international phone number of the contact, formatted according to E.164 (https://wikipedia.org/wiki/E.164).';
COMMENT ON COLUMN maevsi.contact.timezone IS 'Timezone of the contact in ISO 8601 format, e.g., `+02:00`, `-05:30`, or `Z`.';
COMMENT ON COLUMN maevsi.contact.url IS 'URL associated with the contact, must start with "https://" and be up to 300 characters.';
COMMENT ON COLUMN maevsi.contact.created_at IS E'@omit create,update\nTimestamp when the contact was created. Defaults to the current timestamp.';
COMMENT ON CONSTRAINT contact_author_account_id_account_id_key ON maevsi.contact IS 'Ensures the uniqueness of the combination of `author_account_id` and `account_id` for a contact.';

-- GRANTs, RLS and POLICYs are specified in 'table_contact_policy`.

CREATE FUNCTION maevsi.trigger_contact_update_account_id() RETURNS TRIGGER AS $$
  BEGIN
    IF (
      -- invoked without account it
      maevsi.invoker_account_id() IS NULL
      OR
      -- invoked with account it
      -- and
      (
        -- updating own account's contact
        OLD.account_id = maevsi.invoker_account_id()
        AND
        OLD.author_account_id = maevsi.invoker_account_id()
        AND
        (
          -- trying to detach from account
          NEW.account_id != OLD.account_id
          OR
          NEW.author_account_id != OLD.author_account_id
        )
      )
    ) THEN
      RAISE 'You cannot remove the association of your account''s own contact with your account.' USING ERRCODE = 'foreign_key_violation';
    END IF;

    RETURN NEW;
  END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.trigger_contact_update_account_id() IS 'Prevents invalid updates to contacts.';

GRANT EXECUTE ON FUNCTION maevsi.trigger_contact_update_account_id() TO maevsi_account;

CREATE TRIGGER maevsi_trigger_contact_update_account_id
  BEFORE
    UPDATE OF account_id, author_account_id
  ON maevsi.contact
  FOR EACH ROW
  EXECUTE PROCEDURE maevsi.trigger_contact_update_account_id();

COMMIT;
