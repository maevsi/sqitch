BEGIN;

CREATE TABLE maevsi.event_group (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at            TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

  author_account_id     UUID NOT NULL REFERENCES maevsi.account(id),
  "description"         TEXT CHECK (char_length("description") < 1000000),
  is_archived           BOOLEAN NOT NULL DEFAULT FALSE,
  "name"                TEXT NOT NULL CHECK (char_length("name") > 0 AND char_length("name") < 100),
  slug                  TEXT NOT NULL CHECK (char_length(slug) < 100 AND slug ~ '^[-A-Za-z0-9]+$'),
  UNIQUE (author_account_id, slug)
);

COMMENT ON TABLE maevsi.event_group IS 'A group of events.';
COMMENT ON COLUMN maevsi.event_group.id IS E'@omit create,update\nThe event group''s internal id.';
COMMENT ON COLUMN maevsi.event_group.created_at IS E'@omit create\nTimestamp of when the event group was created, defaults to the current timestamp.';
COMMENT ON COLUMN maevsi.event_group.author_account_id IS 'The event group author''s id.';
COMMENT ON COLUMN maevsi.event_group.description IS 'The event group''s description.';
COMMENT ON COLUMN maevsi.event_group.is_archived IS 'Indicates whether the event group is archived.';
COMMENT ON COLUMN maevsi.event_group.name IS 'The event group''s name.';
COMMENT ON COLUMN maevsi.event_group.slug IS E'@omit create,update\nThe event group''s name, slugified.';

GRANT SELECT ON TABLE maevsi.event_group TO maevsi_account, maevsi_anonymous;
GRANT INSERT, UPDATE, DELETE ON TABLE maevsi.event_group TO maevsi_account;

ALTER TABLE maevsi.event_group ENABLE ROW LEVEL SECURITY;

-- TODO:
-- CREATE POLICY event_group_select ON maevsi.event_group FOR SELECT USING (
--     id IN (
--         SELECT event_group_id FROM maevsi.event_grouping
--     )
-- );

COMMIT;
