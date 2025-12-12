BEGIN;

CREATE TABLE vibetype.event_format_mapping (
  event_id  UUID NOT NULL REFERENCES vibetype.event(id) ON DELETE CASCADE,
  format_id UUID NOT NULL REFERENCES vibetype.event_format(id) ON DELETE CASCADE,

  PRIMARY KEY (event_id, format_id)
);

COMMENT ON TABLE vibetype.event_format_mapping IS 'Mapping events to formats (M:N relationship).';
COMMENT ON COLUMN vibetype.event_format_mapping.event_id IS 'An event id.';
COMMENT ON COLUMN vibetype.event_format_mapping.format_id IS 'A format id.';

GRANT SELECT ON TABLE vibetype.event_format_mapping TO vibetype_anonymous;
GRANT SELECT, INSERT, DELETE ON TABLE vibetype.event_format_mapping TO vibetype_account;

ALTER TABLE vibetype.event_format_mapping ENABLE ROW LEVEL SECURITY;

-- Only allow selects for accessible events.
CREATE POLICY event_format_mapping_select ON vibetype.event_format_mapping FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM vibetype.event e WHERE e.id = event_format_mapping.event_id
  )
);

-- Only allow inserts for events created by user.
CREATE POLICY event_format_mapping_insert ON vibetype.event_format_mapping FOR INSERT WITH CHECK (
  (SELECT created_by FROM vibetype.event WHERE id = event_id) = vibetype.invoker_account_id()
);

-- Only allow deletes for events created by user.
CREATE POLICY event_format_mapping_delete ON vibetype.event_format_mapping FOR DELETE USING (
  (SELECT created_by FROM vibetype.event WHERE id = event_id) = vibetype.invoker_account_id()
);

COMMIT;
