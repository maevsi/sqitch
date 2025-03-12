BEGIN;

CREATE TABLE vibetype.event_grouping (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  event_group_id    UUID NOT NULL REFERENCES vibetype.event_group(id),
  event_id          UUID NOT NULL REFERENCES vibetype.event(id),

  UNIQUE (event_id, event_group_id)
);

COMMENT ON TABLE vibetype.event_grouping IS 'A bidirectional mapping between an event and an event group.';
COMMENT ON COLUMN vibetype.event_grouping.id IS E'@omit create,update\nThe event grouping''s internal id.';
COMMENT ON COLUMN vibetype.event_grouping.event_group_id IS 'The event grouping''s internal event group id.';
COMMENT ON COLUMN vibetype.event_grouping.event_id IS 'The event grouping''s internal event id.';

GRANT SELECT ON TABLE vibetype.event_grouping TO vibetype_account, vibetype_anonymous;
GRANT INSERT, UPDATE, DELETE ON TABLE vibetype.event_grouping TO vibetype_account;

ALTER TABLE vibetype.event_grouping ENABLE ROW LEVEL SECURITY;

-- TODO:
-- CREATE POLICY event_grouping_select ON vibetype.event_grouping FOR SELECT USING (
--     event_id IN (
--         SELECT id FROM vibetype.event
--     )
-- );

COMMIT;
