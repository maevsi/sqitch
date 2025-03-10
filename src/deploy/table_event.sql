BEGIN;

CREATE TABLE vibetype.event (
  id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  address_id               UUID REFERENCES vibetype.address(id),
  description              TEXT CHECK (char_length("description") > 0 AND char_length("description") < 1000000),
  "end"                    TIMESTAMP WITH TIME ZONE,
  guest_count_maximum    INTEGER CHECK (guest_count_maximum > 0),
  is_archived              BOOLEAN NOT NULL DEFAULT FALSE,
  is_in_person             BOOLEAN,
  is_remote                BOOLEAN,
  language                 vibetype.language,
  name                     TEXT NOT NULL CHECK (char_length("name") > 0 AND char_length("name") < 100),
  slug                     TEXT NOT NULL CHECK (char_length(slug) < 100 AND slug ~ '^[-A-Za-z0-9]+$'),
  start                    TIMESTAMP WITH TIME ZONE NOT NULL,
  url                      TEXT CHECK (char_length("url") < 300 AND "url" ~ '^https:\/\/'),
  visibility               vibetype.event_visibility NOT NULL,

  created_at               TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by               UUID NOT NULL REFERENCES vibetype.account(id),
  search_vector            TSVECTOR,

  UNIQUE (created_by, slug)
);

CREATE INDEX idx_event_search_vector ON vibetype.event USING gin (search_vector);

COMMENT ON TABLE vibetype.event IS 'An event.';
COMMENT ON COLUMN vibetype.event.id IS E'@omit create,update\nThe event''s internal id.';
COMMENT ON COLUMN vibetype.event.address_id IS 'Optional reference to the physical address of the event.';
COMMENT ON COLUMN vibetype.event.description IS 'The event''s description.';
COMMENT ON COLUMN vibetype.event.end IS 'The event''s end date and time, with timezone.';
COMMENT ON COLUMN vibetype.event.guest_count_maximum IS 'The event''s maximum guest count.';
COMMENT ON COLUMN vibetype.event.is_archived IS 'Indicates whether the event is archived.';
COMMENT ON COLUMN vibetype.event.is_in_person IS 'Indicates whether the event takes place in person.';
COMMENT ON COLUMN vibetype.event.is_remote IS 'Indicates whether the event takes place remotely.';
COMMENT ON COLUMN vibetype.event.name IS 'The event''s name.';
COMMENT ON COLUMN vibetype.event.slug IS 'The event''s name, slugified.';
COMMENT ON COLUMN vibetype.event.start IS 'The event''s start date and time, with timezone.';
COMMENT ON COLUMN vibetype.event.url IS 'The event''s unified resource locator.';
COMMENT ON COLUMN vibetype.event.visibility IS 'The event''s visibility.';
COMMENT ON COLUMN vibetype.event.created_at IS E'@omit create,update\nTimestamp of when the event was created, defaults to the current timestamp.';
COMMENT ON COLUMN vibetype.event.created_by IS 'The event creator''s id.';
COMMENT ON COLUMN vibetype.event.search_vector IS E'@omit\nA vector used for full-text search on events.';
COMMENT ON INDEX vibetype.idx_event_search_vector IS 'GIN index on the search vector to improve full-text search performance.';

CREATE FUNCTION vibetype.trigger_event_search_vector() RETURNS TRIGGER AS $$
DECLARE
  ts_config regconfig;
BEGIN
  ts_config := vibetype.language_iso_full_text_search(NEW.language);

  NEW.search_vector :=
    setweight(to_tsvector(ts_config, NEW.name), 'A') ||
    setweight(to_tsvector(ts_config, coalesce(NEW.description, '')), 'B');

  RETURN NEW;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.trigger_event_search_vector() IS 'Generates a search vector for the event based on the name and description columns, weighted by their relevance and language configuration.';

GRANT EXECUTE ON FUNCTION vibetype.trigger_event_search_vector() TO vibetype_account, vibetype_anonymous;

CREATE TRIGGER vibetype_trigger_event_search_vector
  BEFORE
       INSERT
    OR UPDATE OF name, description, language
  ON vibetype.event
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.trigger_event_search_vector();

-- GRANTs, RLS and POLICYs are specified in `table_event_policy`.

COMMIT;
