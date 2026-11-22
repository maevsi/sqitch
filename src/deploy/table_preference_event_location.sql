BEGIN;

CREATE TABLE vibetype.preference_event_location (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  location            GEOGRAPHY(Point, 4326) NOT NULL,
  radius              FLOAT NOT NULL CHECK (radius > 0),

  created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by          UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,

  UNIQUE (created_by, location, radius)
);

COMMENT ON TABLE vibetype.preference_event_location IS 'Stores preferred event locations for user accounts, including coordinates and search radius.';
COMMENT ON COLUMN vibetype.preference_event_location.id IS E'@behavior -insert\nUnique identifier for the preference record.';
COMMENT ON COLUMN vibetype.preference_event_location.location IS 'Geographical point representing the preferred location, derived from latitude and longitude.';
COMMENT ON COLUMN vibetype.preference_event_location.radius IS 'Search radius in meters around the location where events are preferred. Must be positive.';
COMMENT ON COLUMN vibetype.preference_event_location.created_at IS E'@behavior -insert\nTimestamp of when the event location preference was created, defaults to the current timestamp.';
COMMENT ON COLUMN vibetype.preference_event_location.created_by IS 'Reference to the account that created the location preference.';

GRANT SELECT, INSERT, DELETE ON TABLE vibetype.preference_event_location TO vibetype_account;

ALTER TABLE vibetype.preference_event_location ENABLE ROW LEVEL SECURITY;

CREATE POLICY preference_event_location_all ON vibetype.preference_event_location FOR ALL
USING (
  created_by = vibetype.invoker_account_id()
);

END;
