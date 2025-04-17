BEGIN;

CREATE TABLE vibetype.event_category(
  id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name  TEXT NOT NULL,

  CONSTRAINT unique_event_category_name UNIQUE(name)
);

COMMENT ON TABLE vibetype.event_category IS 'Event categories.';
COMMENT ON COLUMN vibetype.event_category.id IS 'The id of the event category.';
COMMENT ON COLUMN vibetype.event_category.name IS 'A category name.';

GRANT SELECT ON TABLE vibetype.event_category TO vibetype_anonymous, vibetype_account;

-- no row level security necessary for this table as it does not contain user data

END;
