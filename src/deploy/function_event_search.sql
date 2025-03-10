BEGIN;

CREATE FUNCTION vibetype.event_search(
  query TEXT,
  language vibetype.language
) RETURNS SETOF vibetype.event AS $$
DECLARE
  ts_config regconfig;
BEGIN
  ts_config := vibetype.language_iso_full_text_search(event_search.language);

  RETURN QUERY
  SELECT
    *
  FROM
    vibetype.event
  WHERE
    search_vector @@ websearch_to_tsquery(ts_config, event_search.query)
  ORDER BY
    ts_rank_cd(search_vector, websearch_to_tsquery(ts_config, event_search.query)) DESC;
END;
$$ LANGUAGE PLPGSQL STABLE SECURITY INVOKER;

COMMENT ON FUNCTION vibetype.event_search(TEXT, vibetype.language) IS 'Performs a full-text search on the event table based on the provided query and language, returning event IDs ordered by relevance.';

GRANT EXECUTE ON FUNCTION vibetype.event_search(TEXT, vibetype.language) TO vibetype_account, vibetype_anonymous;

COMMIT;
