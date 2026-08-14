BEGIN;

-- Opt the event table and its `start`/`end` columns into PostGraphile's
-- connection filter plugin, which is configured to be opt-in by default
-- (see `maevsi/postgraphile`'s `defaultBehavior`). No other table or column
-- is affected: filtering stays disabled everywhere else.
COMMENT ON TABLE vibetype.event IS E'@behavior +filter\nAn event.';

COMMENT ON COLUMN vibetype.event.start IS E'@behavior +filterBy\nThe event''s start date and time, with time zone.';
COMMENT ON COLUMN vibetype.event.end IS E'@behavior +filterBy\nThe event''s end date and time, with time zone.';

COMMIT;
