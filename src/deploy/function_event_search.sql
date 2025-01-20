BEGIN;

CREATE FUNCTION maevsi.event_search(
  query TEXT,
  language maevsi.language
) RETURNS TABLE(
  event_id UUID
) AS $$
DECLARE
  ts_config TEXT;
BEGIN
  ts_config := maevsi_private.language_iso_full_text_search(event_search.language);

  RETURN QUERY
  SELECT
    id
  FROM
    event
  WHERE
    search_vector @@ plainto_tsquery(ts_config, event_search.query)
  ORDER BY
    ts_rank_cd(search_vector, plainto_tsquery(ts_config, event_search.query)) DESC;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.event_search(TEXT, maevsi.language) IS 'Performs a full-text search on the event table based on the provided query and language, returning event IDs ordered by relevance.';

GRANT EXECUTE ON FUNCTION maevsi.event_search(TEXT, maevsi.language) TO maevsi_account, maevsi_anonymous;

COMMIT;
