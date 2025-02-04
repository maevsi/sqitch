BEGIN;

CREATE TABLE maevsi.event_grouping (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  event_group_id    UUID NOT NULL REFERENCES maevsi.event_group(id),
  event_id          UUID NOT NULL REFERENCES maevsi.event(id),

  UNIQUE (event_id, event_group_id)
);

CREATE INDEX idx_event_grouping_event_group_id ON maevsi.event_grouping USING btree (event_group_id);
CREATE INDEX idx_event_grouping_event_id ON maevsi.event_grouping USING btree (event_id);

COMMENT ON TABLE maevsi.event_grouping IS 'A bidirectional mapping between an event and an event group.';
COMMENT ON COLUMN maevsi.event_grouping.id IS E'@omit create,update\nThe event grouping''s internal id.';
COMMENT ON COLUMN maevsi.event_grouping.event_group_id IS 'The event grouping''s internal event group id.';
COMMENT ON COLUMN maevsi.event_grouping.event_id IS 'The event grouping''s internal event id.';
COMMENT ON INDEX maevsi.idx_event_grouping_event_group_id IS 'B-Tree index to optimize lookups by event group foreign key.';
COMMENT ON INDEX maevsi.idx_event_grouping_event_id IS 'B-Tree index to optimize lookups by event foreign key.';

GRANT SELECT ON TABLE maevsi.event_grouping TO maevsi_account, maevsi_anonymous;
GRANT INSERT, UPDATE, DELETE ON TABLE maevsi.event_grouping TO maevsi_account;

ALTER TABLE maevsi.event_grouping ENABLE ROW LEVEL SECURITY;

-- TODO:
-- CREATE POLICY event_grouping_select ON maevsi.event_grouping FOR SELECT USING (
--     event_id IN (
--         SELECT id FROM maevsi.event
--     )
-- );

COMMIT;
