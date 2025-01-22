BEGIN;

CREATE TABLE maevsi.event_category_mapping (
  event_id uuid NOT NULL REFERENCES maevsi.event(id) ON DELETE CASCADE,
  category TEXT NOT NULL REFERENCES maevsi.event_category(category) ON DELETE CASCADE,

  PRIMARY KEY (event_id, category)
);

COMMENT ON TABLE maevsi.event_category_mapping IS 'Mapping events to categories (M:N relationship).';
COMMENT ON COLUMN maevsi.event_category_mapping.event_id IS 'An event id.';
COMMENT ON COLUMN maevsi.event_category_mapping.category IS 'A category name.';

COMMIT;
