BEGIN;

CREATE OR REPLACE FUNCTION vibetype.event_search(query text, language vibetype.language) RETURNS SETOF vibetype.event
    LANGUAGE sql STABLE
    AS $$
  SELECT e.*
  FROM
    vibetype.event e,
    (SELECT vibetype.language_iso_full_text_search(event_search.language) AS ts_config) t
  WHERE
    e.search_vector @@ websearch_to_tsquery(t.ts_config, event_search.query)
    AND e.effective_end >= now()
  ORDER BY
    ts_rank_cd(e.search_vector, websearch_to_tsquery(t.ts_config, event_search.query)) DESC;
$$;

COMMENT ON FUNCTION vibetype.event_search(TEXT, vibetype.language) IS 'Performs a full-text search on events that have not ended yet, based on the provided query and language, returning results ordered by relevance.';

COMMIT;
