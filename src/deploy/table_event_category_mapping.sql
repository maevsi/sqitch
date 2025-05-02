BEGIN;

CREATE TABLE vibetype.event_category_mapping (
  event_id    UUID NOT NULL REFERENCES vibetype.event(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES vibetype.event_category(id) ON DELETE CASCADE,

  PRIMARY KEY (event_id, category_id)
);

COMMENT ON TABLE vibetype.event_category_mapping IS 'Mapping events to categories (M:N relationship).';
COMMENT ON COLUMN vibetype.event_category_mapping.event_id IS 'An event id.';
COMMENT ON COLUMN vibetype.event_category_mapping.category_id IS 'A category id.';

GRANT SELECT ON TABLE vibetype.event_category_mapping TO vibetype_anonymous;
GRANT SELECT, INSERT, DELETE ON TABLE vibetype.event_category_mapping TO vibetype_account;

ALTER TABLE vibetype.event_category_mapping ENABLE ROW LEVEL SECURITY;

CREATE POLICY event_category_mapping_select ON vibetype.event_category_mapping FOR SELECT
USING (
  -- same policy as for table event
  event_id IN (SELECT id FROM vibetype.event)
);

CREATE POLICY event_category_mapping_insert ON vibetype.event_category_mapping FOR INSERT
WITH CHECK (
  (SELECT created_by FROM vibetype.event WHERE id = event_id) = vibetype.invoker_account_id()
);

CREATE POLICY event_category_mapping_delete ON vibetype.event_category_mapping FOR DELETE
USING (
  (SELECT created_by FROM vibetype.event WHERE id = event_id) = vibetype.invoker_account_id()
);

COMMIT;
