BEGIN;

CREATE TABLE vibetype.event_category_mapping (
  event_id    UUID NOT NULL REFERENCES vibetype.event(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES vibetype.event_category(id) ON DELETE CASCADE,

  PRIMARY KEY (event_id, category_id)
);

COMMENT ON TABLE vibetype.event_category_mapping IS 'Mapping events to categories (M:N relationship).';
COMMENT ON COLUMN vibetype.event_category_mapping.event_id IS 'An event id.';
COMMENT ON COLUMN vibetype.event_category_mapping.category_id IS 'A category id.';

COMMIT;
