BEGIN;

CREATE TABLE vibetype.event_format(
  id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name  TEXT,

  CONSTRAINT unique_event_format_name UNIQUE(name)
);

COMMENT ON TABLE vibetype.event_format IS 'Event formats.';
COMMENT ON COLUMN vibetype.event_format.id IS 'The id of the event format.';
COMMENT ON COLUMN vibetype.event_format.name IS 'The name of the event format.';

GRANT SELECT ON TABLE vibetype.event_format TO vibetype_anonymous, vibetype_account;

-- no row level security necessary for this table as it does not contain user data

END;
