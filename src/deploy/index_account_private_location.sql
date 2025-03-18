BEGIN;

CREATE INDEX idx_account_private_location ON vibetype_private.account USING GIST (location);

COMMENT ON INDEX vibetype_private.idx_account_private_location IS 'Spatial index on column location in vibetype_private.account.';

COMMIT;
