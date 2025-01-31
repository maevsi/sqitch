BEGIN;

CREATE FUNCTION maevsi.event_search(
  query TEXT,
  language maevsi.language
) RETURNS SETOF maevsi.event AS $$
DECLARE
  ts_config regconfig;
BEGIN
  ts_config := maevsi.language_iso_full_text_search(event_search.language);

  RETURN QUERY
  SELECT
    *
  FROM
    maevsi.event
  WHERE
    search_vector @@ websearch_to_tsquery(ts_config, event_search.query)
  ORDER BY
    ts_rank_cd(search_vector, websearch_to_tsquery(ts_config, event_search.query)) DESC;
END;
$$ LANGUAGE PLPGSQL STABLE SECURITY INVOKER;

COMMENT ON FUNCTION maevsi.event_search(TEXT, maevsi.language) IS 'Performs a full-text search on the event table based on the provided query and language, returning event IDs ordered by relevance.';

GRANT EXECUTE ON FUNCTION maevsi.event_search(TEXT, maevsi.language) TO maevsi_account, maevsi_anonymous;

COMMIT;
