BEGIN;

DROP FUNCTION vibetype.event_search(TEXT);

CREATE FUNCTION vibetype.event_search(query text, include_ended boolean DEFAULT false) RETURNS SETOF vibetype.event
    LANGUAGE sql STABLE
    AS $$
  -- Falls back to trigram similarity on the name for typo tolerance, alongside the prefix match from event_search_rank().
  -- The caller does not need to know (or guess) which language a given event was authored in; see vibetype_private.event_search_vector and the trigger that populates it.
  SELECT e.*
  FROM vibetype.event_search_match(event_search.query) m
  JOIN vibetype.event e ON e.id = m.event_id
  WHERE
    COALESCE(event_search.include_ended, false)
    OR e.effective_end >= now()
  ORDER BY
    m.score DESC,
    e.id;
$$;

COMMENT ON FUNCTION vibetype.event_search(TEXT, BOOLEAN) IS 'Searches events by name and description. Matches by prefix so partial words match as the user types, and falls back to trigram similarity on the name for typo tolerance. Events that have ended are left out unless `include_ended` is true. Following RFC 5545, an event without an end ends at its start. Ordering is fully deterministic, so paginate through results via the GraphQL connection arguments rather than assuming a fixed result size.';

GRANT EXECUTE ON FUNCTION vibetype.event_search(TEXT, BOOLEAN) TO vibetype_account;

COMMIT;
