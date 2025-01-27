BEGIN;

CREATE TABLE maevsi.event (
  id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  address                  UUID REFERENCES maevsi.address(id),
  author_account_id        UUID NOT NULL REFERENCES maevsi.account(id),
  description              TEXT CHECK (char_length("description") > 0 AND char_length("description") < 1000000),
  "end"                    TIMESTAMP WITH TIME ZONE,
  invitee_count_maximum    INTEGER CHECK (invitee_count_maximum > 0),
  is_archived              BOOLEAN NOT NULL DEFAULT FALSE,
  is_in_person             BOOLEAN,
  is_remote                BOOLEAN,
  language                 maevsi.language,
  location                 TEXT CHECK (char_length("location") > 0 AND char_length("location") < 300),
  location_geography       GEOGRAPHY(Point, 4326),
  name                     TEXT NOT NULL CHECK (char_length("name") > 0 AND char_length("name") < 100),
  slug                     TEXT NOT NULL CHECK (char_length(slug) < 100 AND slug ~ '^[-A-Za-z0-9]+$'),
  start                    TIMESTAMP WITH TIME ZONE NOT NULL,
  url                      TEXT CHECK (char_length("url") < 300 AND "url" ~ '^https:\/\/'),
  visibility               maevsi.event_visibility NOT NULL,

  created_at               TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  search_vector            TSVECTOR,

  UNIQUE (author_account_id, slug)
);

COMMENT ON TABLE maevsi.event IS 'An event.';
COMMENT ON COLUMN maevsi.event.id IS E'@omit create,update\nThe event''s internal id.';
COMMENT ON COLUMN maevsi.event.address IS 'The event''s physical address.';
COMMENT ON COLUMN maevsi.event.author_account_id IS 'The event author''s id.';
COMMENT ON COLUMN maevsi.event.description IS 'The event''s description.';
COMMENT ON COLUMN maevsi.event.end IS 'The event''s end date and time, with timezone.';
COMMENT ON COLUMN maevsi.event.invitee_count_maximum IS 'The event''s maximum invitee count.';
COMMENT ON COLUMN maevsi.event.is_archived IS 'Indicates whether the event is archived.';
COMMENT ON COLUMN maevsi.event.is_in_person IS 'Indicates whether the event takes place in person.';
COMMENT ON COLUMN maevsi.event.is_remote IS 'Indicates whether the event takes place remotely.';
COMMENT ON COLUMN maevsi.event.location IS 'The event''s location as it can be shown on a map.';
COMMENT ON COLUMN maevsi.event.location_geography IS 'The event''s geographic location.';
COMMENT ON COLUMN maevsi.event.name IS 'The event''s name.';
COMMENT ON COLUMN maevsi.event.slug IS 'The event''s name, slugified.';
COMMENT ON COLUMN maevsi.event.start IS 'The event''s start date and time, with timezone.';
COMMENT ON COLUMN maevsi.event.url IS 'The event''s unified resource locator.';
COMMENT ON COLUMN maevsi.event.visibility IS 'The event''s visibility.';
COMMENT ON COLUMN maevsi.event.created_at IS E'@omit create,update\nTimestamp of when the event was created, defaults to the current timestamp.';
COMMENT ON COLUMN maevsi.event.search_vector IS E'@omit\nA vector used for full-text search on events.';

CREATE INDEX idx_event_search_vector ON maevsi.event USING GIN(search_vector);

CREATE FUNCTION maevsi.trigger_event_search_vector() RETURNS TRIGGER AS $$
DECLARE
  ts_config regconfig;
BEGIN
  ts_config := maevsi.language_iso_full_text_search(NEW.language);

  NEW.search_vector :=
    setweight(to_tsvector(ts_config, NEW.name), 'A') ||
    setweight(to_tsvector(ts_config, coalesce(NEW.description, '')), 'B');

  RETURN NEW;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.trigger_event_search_vector() IS 'Generates a search vector for the event based on the name and description columns, weighted by their relevance and language configuration.';

GRANT EXECUTE ON FUNCTION maevsi.trigger_event_search_vector() TO maevsi_account, maevsi_anonymous;

CREATE TRIGGER maevsi_trigger_event_search_vector
  BEFORE
       INSERT
    OR UPDATE OF name, description, language
  ON maevsi.event
  FOR EACH ROW
  EXECUTE FUNCTION maevsi.trigger_event_search_vector();

-- GRANTs, RLS and POLICYs are specified in 'table_event_policy`.

COMMIT;
