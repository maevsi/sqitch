BEGIN;

CREATE TABLE maevsi.event_category(
    category TEXT PRIMARY KEY
);

COMMENT ON TABLE maevsi.event_category IS 'Event categories.';
COMMENT ON COLUMN maevsi.event_category.category IS 'A category name.';

END;
