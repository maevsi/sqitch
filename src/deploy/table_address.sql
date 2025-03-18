BEGIN;

CREATE TABLE vibetype.address (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  name        TEXT NOT NULL CHECK (char_length(name) > 0 AND char_length(name) <= 300),
  line_1      TEXT NOT NULL CHECK (char_length(line_1) > 0 AND char_length(line_1) <= 300),
  line_2      TEXT CHECK (char_length(line_2) > 0 AND char_length(line_2) <= 300),
  postal_code TEXT NOT NULL CHECK (char_length(postal_code) > 0 AND char_length(postal_code) <= 20),
  city        TEXT NOT NULL CHECK (char_length(city) > 0 AND char_length(city) <= 300),
  region      TEXT NOT NULL CHECK (char_length(region) > 0 AND char_length(region) <= 300),
  country     TEXT NOT NULL CHECK (char_length(country) > 0 AND char_length(country) <= 300),

  created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by  UUID REFERENCES vibetype.account(id) NOT NULL,
  updated_at  TIMESTAMP WITH TIME ZONE,
  updated_by  UUID REFERENCES vibetype.account(id) NOT NULL
);

COMMENT ON TABLE vibetype.address IS 'Stores detailed address information, including lines, city, state, country, and metadata.';

COMMENT ON COLUMN vibetype.address.id IS E'@omit create,update\nPrimary key, uniquely identifies each address.';
COMMENT ON COLUMN vibetype.address.name IS 'Person or company name. Must be between 1 and 300 characters.';
COMMENT ON COLUMN vibetype.address.line_1 IS 'First line of the address (e.g., street address). Must be between 1 and 300 characters.';
COMMENT ON COLUMN vibetype.address.line_2 IS 'Second line of the address, if needed. Must be between 1 and 300 characters.';
COMMENT ON COLUMN vibetype.address.postal_code IS 'Postal or ZIP code for the address. Must be between 1 and 20 characters.';
COMMENT ON COLUMN vibetype.address.city IS 'City of the address. Must be between 1 and 300 characters.';
COMMENT ON COLUMN vibetype.address.region IS 'Region of the address (e.g., state, province, county, department or territory). Must be between 1 and 300 characters.';
COMMENT ON COLUMN vibetype.address.country IS 'Country of the address. Must be between 1 and 300 characters.';
COMMENT ON COLUMN vibetype.address.created_at IS E'@omit create,update\nTimestamp when the address was created. Defaults to the current timestamp.';
COMMENT ON COLUMN vibetype.address.created_by IS E'@omit create,update\nReference to the account that created the address.';
COMMENT ON COLUMN vibetype.address.updated_at IS E'@omit create,update\nTimestamp when the address was last updated.';
COMMENT ON COLUMN vibetype.address.updated_by IS E'@omit create,update\nReference to the account that last updated the address.';

-- GRANTs, RLS and POLICYs are specified in 'table_address_policy`.

CREATE TRIGGER vibetype_trigger_address_update
  BEFORE
    UPDATE
  ON vibetype.address
  FOR EACH ROW
  EXECUTE PROCEDURE vibetype.trigger_metadata_update();

COMMIT;
