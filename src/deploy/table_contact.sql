-- Deploy maevsi:table_contact to pg
-- requires: schema_public
-- requires: role_account
-- requires: role_anonymous
-- requires: table_account_public

BEGIN;

CREATE TABLE maevsi.contact (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id            UUID REFERENCES maevsi.account(id),
  "address"             TEXT CHECK (char_length("address") > 0 AND char_length("address") < 300),
  author_account_id     UUID NOT NULL REFERENCES maevsi.account(id) ON DELETE CASCADE,
  email_address         TEXT CHECK (char_length(email_address) < 255), -- no regex check as "a valid email address is one that you can send emails to" (http://www.dominicsayers.com/isemail/)
  email_address_hash    TEXT GENERATED ALWAYS AS (md5(lower(substring(email_address, '\S(?:.*\S)*')))) STORED, -- for gravatar profile pictures
  first_name            TEXT CHECK (char_length(first_name) > 0 AND char_length(first_name) < 100),
  last_name             TEXT CHECK (char_length(last_name) > 0 AND char_length(last_name) < 100),
  phone_number          TEXT CHECK (phone_number ~ '^\+(?:[0-9] ?){6,14}[0-9]$'), -- E.164 format (https://wikipedia.org/wiki/E.164)
  "url"                 TEXT CHECK (char_length("url") < 300 AND "url" ~ '^https:\/\/'),
  UNIQUE (author_account_id, account_id)
);

COMMENT ON TABLE maevsi.contact IS 'Contact data.';
COMMENT ON COLUMN maevsi.contact.id IS E'@omit create,update\nThe contact''s internal id.';
COMMENT ON COLUMN maevsi.contact.account_id IS 'The contact account''s id.';
COMMENT ON COLUMN maevsi.contact.address IS 'The contact''s physical address.';
COMMENT ON COLUMN maevsi.contact.author_account_id IS 'The contact author''s id.';
COMMENT ON COLUMN maevsi.contact.email_address IS 'The contact''s email address.';
COMMENT ON COLUMN maevsi.contact.email_address_hash IS E'@omit create,update\nThe contact''s email address''s md5 hash.';
COMMENT ON COLUMN maevsi.contact.first_name IS 'The contact''s first name.';
COMMENT ON COLUMN maevsi.contact.last_name IS 'The contact''s last name.';
COMMENT ON COLUMN maevsi.contact.phone_number IS 'The contact''s international phone number.';
COMMENT ON COLUMN maevsi.contact.url IS 'The contact''s website url.';

-- GRANTs, RLS and POLICYs are specified in 'table_contact_policy`.

CREATE FUNCTION maevsi.trigger_contact_update_account_id() RETURNS TRIGGER AS $$
  BEGIN
    IF (
      -- invoked without account it
      NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NULL
      OR
      -- invoked with account it
      -- and
      (
        -- updating own account's contact
        OLD.account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
        AND
        OLD.author_account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
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
