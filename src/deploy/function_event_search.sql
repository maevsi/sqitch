BEGIN;

CREATE FUNCTION vibetype.event_search(query text, language vibetype.language) RETURNS SETOF vibetype.event
    LANGUAGE sql STABLE
    AS $$
  SELECT e.*
  FROM
    vibetype.event e,
    (SELECT vibetype.language_iso_full_text_search(event_search.language) AS ts_config) t
  WHERE
    e.search_vector @@ websearch_to_tsquery(t.ts_config, event_search.query)
  ORDER BY
    ts_rank_cd(e.search_vector, websearch_to_tsquery(t.ts_config, event_search.query)) DESC;
$$;

COMMENT ON FUNCTION vibetype.event_search(TEXT, vibetype.language) IS 'Performs a full-text search on the event table based on the provided query and language, returning event IDs ordered by relevance.';

GRANT EXECUTE ON FUNCTION vibetype.event_search(TEXT, vibetype.language) TO vibetype_account, vibetype_anonymous;

COMMIT;
