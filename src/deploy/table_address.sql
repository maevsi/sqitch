BEGIN;

CREATE TABLE vibetype.address (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  city        TEXT CHECK (char_length(city) > 0 AND char_length(city) <= 300),
  country     TEXT CHECK (char_length(country) > 0 AND char_length(country) <= 300),
  line_1      TEXT CHECK (char_length(line_1) > 0 AND char_length(line_1) <= 300),
  line_2      TEXT CHECK (char_length(line_2) > 0 AND char_length(line_2) <= 300),
  location    GEOGRAPHY(Point, 4326),
  name        TEXT NOT NULL CHECK (char_length(name) > 0 AND char_length(name) <= 300),
  postal_code TEXT CHECK (char_length(postal_code) > 0 AND char_length(postal_code) <= 20),
  region      TEXT CHECK (char_length(region) > 0 AND char_length(region) <= 300),

  created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by  UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,
  updated_at  TIMESTAMP WITH TIME ZONE,
  updated_by  UUID REFERENCES vibetype.account(id) ON DELETE SET NULL
);

CREATE INDEX idx_address_location ON vibetype.address USING gist (location);
CREATE INDEX idx_address_created_by ON vibetype.address USING btree (created_by);
CREATE INDEX idx_address_updated_by ON vibetype.address USING btree (updated_by);

COMMENT ON TABLE vibetype.address IS 'Stores detailed address information, including lines, city, state, country, and metadata.';
COMMENT ON COLUMN vibetype.address.id IS E'@omit create,update\nPrimary key, uniquely identifies each address.';
COMMENT ON COLUMN vibetype.address.city IS 'City of the address. Must be between 1 and 300 characters.';
COMMENT ON COLUMN vibetype.address.country IS 'Country of the address. Must be between 1 and 300 characters.';
COMMENT ON COLUMN vibetype.address.line_1 IS 'First line of the address (e.g., street address). Must be between 1 and 300 characters.';
COMMENT ON COLUMN vibetype.address.line_2 IS 'Second line of the address, if needed. Must be between 1 and 300 characters.';
COMMENT ON COLUMN vibetype.address.location IS 'The geographic location of the address.';
COMMENT ON COLUMN vibetype.address.name IS 'Person or company name. Must be between 1 and 300 characters.';
COMMENT ON COLUMN vibetype.address.postal_code IS 'Postal or ZIP code for the address. Must be between 1 and 20 characters.';
COMMENT ON COLUMN vibetype.address.region IS 'Region of the address (e.g., state, province, county, department or territory). Must be between 1 and 300 characters.';
COMMENT ON COLUMN vibetype.address.created_at IS E'@omit create,update\nTimestamp when the address was created. Defaults to the current timestamp.';
COMMENT ON COLUMN vibetype.address.created_by IS E'@omit update\nReference to the account that created the address.';
COMMENT ON COLUMN vibetype.address.updated_at IS E'@omit create,update\nTimestamp when the address was last updated.';
COMMENT ON COLUMN vibetype.address.updated_by IS E'@omit create,update\nReference to the account that last updated the address.';
COMMENT ON INDEX vibetype.idx_address_location IS 'GIST index on the location for efficient spatial queries.';
COMMENT ON INDEX vibetype.idx_address_created_by IS 'B-Tree index to optimize lookups by creator.';
COMMENT ON INDEX vibetype.idx_address_updated_by IS 'B-Tree index to optimize lookups by updater.';
-- GRANTs, RLS and POLICYs are specified in `table_address_policy`.

CREATE TRIGGER update
  BEFORE
    UPDATE
  ON vibetype.address
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.trigger_metadata_update();

COMMIT;
