BEGIN;

CREATE INDEX idx_event_location ON vibetype.event USING GIST (location_geography);

COMMENT ON INDEX vibetype.idx_event_location IS 'Spatial index on column location in vibetype.event.';

COMMIT;
