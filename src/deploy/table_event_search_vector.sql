BEGIN;

CREATE TABLE vibetype_private.event_search_vector (
  event_id                 UUID NOT NULL REFERENCES vibetype.event(id) ON DELETE CASCADE,
  ts_config                REGCONFIG NOT NULL,
  search_vector            TSVECTOR NOT NULL,

  PRIMARY KEY (event_id, ts_config)
);

CREATE INDEX idx_event_search_vector ON vibetype_private.event_search_vector USING gin (search_vector);
CREATE INDEX idx_event_search_vector_event_id ON vibetype_private.event_search_vector USING btree (event_id);

COMMENT ON TABLE vibetype_private.event_search_vector IS 'A per-text-search-configuration search vector for an event: one row per configuration `vibetype.language_iso_full_text_search()` currently maps a supported language to (deduplicated), plus a ''simple'' fallback row. Populated by `vibetype.event`''s search_vector trigger; not directly accessible to application roles, only through `vibetype_private.event_search_rank()`.';
COMMENT ON COLUMN vibetype_private.event_search_vector.event_id IS 'The event this search vector belongs to.';
COMMENT ON COLUMN vibetype_private.event_search_vector.ts_config IS 'The text search configuration this vector was built with.';
COMMENT ON COLUMN vibetype_private.event_search_vector.search_vector IS 'A vector used for full-text search on the event, built with ts_config.';
COMMENT ON INDEX vibetype_private.idx_event_search_vector IS 'GIN index on the search vector to improve full-text search performance.';
COMMENT ON INDEX vibetype_private.idx_event_search_vector_event_id IS 'Single-column index on event_id for efficient cascading deletes; the primary key''s composite index does not satisfy this on its own since it also includes ts_config.';

COMMIT;
