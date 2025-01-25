BEGIN;

CREATE INDEX idx_event_location ON maevsi.event USING GIST (location_geography);

COMMENT ON INDEX maevsi.idx_event_location IS 'Spatial index on column location in maevsi.event.';

COMMIT;
