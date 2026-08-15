BEGIN;

CREATE TABLE vibetype.event (
  id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  address_id               UUID REFERENCES vibetype.address(id) ON DELETE SET NULL,
  description              TEXT CHECK (char_length("description") > 0 AND char_length("description") <= 10000),
  "end"                    TIMESTAMP WITH TIME ZONE,
  guest_count_maximum      INTEGER CHECK (guest_count_maximum > 0),
  is_archived              BOOLEAN NOT NULL DEFAULT FALSE,
  is_in_person             BOOLEAN,
  is_remote                BOOLEAN,
  language                 vibetype.language,
  name                     TEXT NOT NULL CHECK (char_length("name") > 0 AND char_length("name") <= 100),
  slug                     TEXT NOT NULL CHECK (char_length(slug) <= 100 AND slug ~ '^[-A-Za-z0-9]+$'),
  start                    TIMESTAMP WITH TIME ZONE NOT NULL,
  url                      TEXT CHECK (char_length("url") <= 2000 AND "url" ~ '^https://[^[:space:]]+$'),
  visibility               vibetype.event_visibility NOT NULL,

  created_at               TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by               UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,

  UNIQUE (created_by, slug)
);

CREATE INDEX idx_event_address_id ON vibetype.event USING btree (address_id);
CREATE INDEX idx_event_created_by ON vibetype.event USING btree (created_by);
CREATE INDEX idx_event_end ON vibetype.event USING btree ("end")
  WHERE "end" IS NOT NULL;
CREATE INDEX idx_event_start ON vibetype.event USING btree (start);
CREATE INDEX idx_event_name_trgm ON vibetype.event USING gin (name gin_trgm_ops);

COMMENT ON TABLE vibetype.event IS 'An event.';
COMMENT ON COLUMN vibetype.event.id IS E'@behavior -insert -update\nThe event''s internal id.';
COMMENT ON COLUMN vibetype.event.address_id IS 'Optional reference to the physical address of the event.';
COMMENT ON COLUMN vibetype.event.description IS 'The event''s description. Must be non-empty and not exceed 10,000 characters.';
COMMENT ON COLUMN vibetype.event.end IS 'The event''s end date and time, with time zone.';
COMMENT ON COLUMN vibetype.event.guest_count_maximum IS 'The event''s maximum guest count. Must be greater than 0.';
COMMENT ON COLUMN vibetype.event.is_archived IS 'Indicates whether the event is archived.';
COMMENT ON COLUMN vibetype.event.is_in_person IS 'Indicates whether the event takes place in person.';
COMMENT ON COLUMN vibetype.event.is_remote IS 'Indicates whether the event takes place remotely.';
COMMENT ON COLUMN vibetype.event.name IS 'The event''s name. Must be non-empty and not exceed 100 characters.';
COMMENT ON COLUMN vibetype.event.slug IS 'The event''s name, slugified. Must be alphanumeric with hyphens and not exceed 100 characters.';
COMMENT ON COLUMN vibetype.event.start IS 'The event''s start date and time, with time zone.';
COMMENT ON COLUMN vibetype.event.url IS 'The event''s unified resource locator. Must start with "https://" and not exceed 2,000 characters.';
COMMENT ON COLUMN vibetype.event.visibility IS 'The event''s visibility.';
COMMENT ON COLUMN vibetype.event.created_at IS E'@behavior -insert -update\nTimestamp of when the event was created, defaults to the current timestamp.';
COMMENT ON COLUMN vibetype.event.created_by IS 'The event creator''s id.';
COMMENT ON INDEX vibetype.idx_event_name_trgm IS 'GIN trigram index on the name, used for prefix and typo-tolerant search fallback.';

CREATE FUNCTION vibetype.trigger_event_search_vector() RETURNS TRIGGER
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _ts_config regconfig;
BEGIN
  -- One row per language `vibetype.language_iso_full_text_search()` currently maps to (derived from the
  -- `vibetype.language` enum, so this automatically picks up newly supported languages, deduplicated by
  -- configuration), plus 'simple' as a fallback for languages not yet mapped to a real configuration.
  -- Keeping one pure, single-configuration vector per row (rather than merging all of them into one,
  -- as an earlier version of this migration did) keeps `ts_rank_cd` scoring undiluted by cross-language
  -- lexeme noise; see `event_search_rank()` for how these get searched without knowing the event's
  -- language up front.
  FOR _ts_config IN
    SELECT DISTINCT vibetype.language_iso_full_text_search(language)
    FROM unnest(enum_range(NULL::vibetype.language)) AS language
    UNION
    SELECT 'simple'::regconfig
  LOOP
    INSERT INTO vibetype_private.event_search_vector (event_id, ts_config, search_vector)
    VALUES (
      NEW.id,
      _ts_config,
      setweight(to_tsvector(_ts_config, NEW.name), 'A') ||
        setweight(to_tsvector(_ts_config, coalesce(NEW.description, '')), 'B')
    )
    ON CONFLICT (event_id, ts_config) DO UPDATE SET search_vector = EXCLUDED.search_vector;
  END LOOP;

  RETURN NEW;
END;
$$;
COMMENT ON FUNCTION vibetype.trigger_event_search_vector() IS 'Populates vibetype_private.event_search_vector with one row per supported text search configuration, based on the name and description columns weighted by their relevance.';
GRANT EXECUTE ON FUNCTION vibetype.trigger_event_search_vector() TO vibetype_account, vibetype_anonymous;

CREATE TRIGGER search_vector
  AFTER
       INSERT
    OR UPDATE OF name, description
  ON vibetype.event
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.trigger_event_search_vector();

-- GRANTs, RLS and POLICYs are specified in `table_event_policy`.

COMMIT;
