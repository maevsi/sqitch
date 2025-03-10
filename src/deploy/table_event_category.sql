BEGIN;

CREATE TABLE vibetype.event_category(
  category TEXT PRIMARY KEY
);

COMMENT ON TABLE vibetype.event_category IS 'Event categories.';
COMMENT ON COLUMN vibetype.event_category.category IS 'A category name.';

END;
