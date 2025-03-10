BEGIN;

CREATE TABLE vibetype.event_category_mapping (
  event_id uuid NOT NULL REFERENCES vibetype.event(id) ON DELETE CASCADE,
  category TEXT NOT NULL REFERENCES vibetype.event_category(category) ON DELETE CASCADE,

  PRIMARY KEY (event_id, category)
);

COMMENT ON TABLE vibetype.event_category_mapping IS 'Mapping events to categories (M:N relationship).';
COMMENT ON COLUMN vibetype.event_category_mapping.event_id IS 'An event id.';
COMMENT ON COLUMN vibetype.event_category_mapping.category IS 'A category name.';

COMMIT;
