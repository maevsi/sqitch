BEGIN;

CREATE INDEX idx_account_location ON maevsi_private.account USING GIST (location);

COMMENT ON INDEX maevsi_private.idx_account_location IS 'Spatial index on column location in maevsi_private.account.';

COMMIT;
