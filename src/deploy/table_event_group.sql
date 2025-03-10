BEGIN;

CREATE TABLE vibetype.event_group (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  description           TEXT CHECK (char_length("description") < 1000000),
  is_archived           BOOLEAN NOT NULL DEFAULT FALSE,
  name                  TEXT NOT NULL CHECK (char_length("name") > 0 AND char_length("name") < 100),
  slug                  TEXT NOT NULL CHECK (char_length(slug) < 100 AND slug ~ '^[-A-Za-z0-9]+$'),

  created_at            TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by            UUID NOT NULL REFERENCES vibetype.account(id),

  UNIQUE (created_by, slug)
);

COMMENT ON TABLE vibetype.event_group IS 'A group of events.';
COMMENT ON COLUMN vibetype.event_group.id IS E'@omit create,update\nThe event group''s internal id.';
COMMENT ON COLUMN vibetype.event_group.description IS 'The event group''s description.';
COMMENT ON COLUMN vibetype.event_group.is_archived IS 'Indicates whether the event group is archived.';
COMMENT ON COLUMN vibetype.event_group.name IS 'The event group''s name.';
COMMENT ON COLUMN vibetype.event_group.slug IS E'@omit create,update\nThe event group''s name, slugified.';
COMMENT ON COLUMN vibetype.event_group.created_at IS E'@omit create,update\nTimestamp of when the event group was created, defaults to the current timestamp.';
COMMENT ON COLUMN vibetype.event_group.created_by IS 'The event group creator''s id.';

GRANT SELECT ON TABLE vibetype.event_group TO vibetype_account, vibetype_anonymous;
GRANT INSERT, UPDATE, DELETE ON TABLE vibetype.event_group TO vibetype_account;

ALTER TABLE vibetype.event_group ENABLE ROW LEVEL SECURITY;

-- TODO:
-- CREATE POLICY event_group_select ON vibetype.event_group FOR SELECT USING (
--     id IN (
--         SELECT event_group_id FROM vibetype.event_grouping
--     )
-- );

COMMIT;
