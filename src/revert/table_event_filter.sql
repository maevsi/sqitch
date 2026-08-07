BEGIN;

COMMENT ON TABLE vibetype.event IS 'An event.';

COMMENT ON COLUMN vibetype.event.start IS 'The event''s start date and time, with time zone.';
COMMENT ON COLUMN vibetype.event.end IS 'The event''s end date and time, with time zone.';

COMMIT;
