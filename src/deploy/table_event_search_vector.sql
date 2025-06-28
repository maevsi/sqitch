BEGIN;

CREATE TABLE vibetype.event_search_vector (
  id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id                 UUID REFERENCES vibetype.event(id) ON DELETE SET NULL,
  language                 vibetype.language NOT NULL,
  search_vector            TSVECTOR,

  UNIQUE (event_id, language)
);

COMMENT ON TABLE vibetype.event_search_vector IS E'@omit create,update,delete\nA language-specific search vector for an event.';
COMMENT ON COLUMN vibetype.event_search_vector.id IS 'The records''s internal id.';
COMMENT ON COLUMN vibetype.event_search_vector.event_id IS 'The reference to the event.';
COMMENT ON COLUMN vibetype.event_search_vector.language IS 'The language associated with the search vector.';
COMMENT ON COLUMN vibetype.event_search_vector.search_vector IS 'A vector used for full-text search on events.';

CREATE INDEX idx_event_search_vector ON vibetype.event_search_vector USING gin (search_vector);

COMMENT ON INDEX vibetype.idx_event_search_vector IS 'GIN index on the search vector to improve full-text search performance.';

GRANT SELECT ON TABLE vibetype.event_search_vector TO vibetype_anonymous;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE vibetype.event_search_vector TO vibetype_account;

CREATE POLICY event_search_vector_select ON vibetype.event_search_vector FOR SELECT
USING (
  event_id IN (SELECT id FROM vibetype_private.event_policy_select())
);

COMMIT;
