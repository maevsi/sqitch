BEGIN;

-- `event_search()` below is SECURITY INVOKER (required for RLS on `vibetype.event` to apply to the
-- caller, not the function owner), and any statement in an invoker-security function's body, in any
-- language, checks privileges against the calling role, including schema-level name resolution. So the
-- caller needs USAGE on `vibetype_private` to even reference this function, not just EXECUTE on it.
-- (RLS policies are a special case that doesn't apply here: a policy expression is pre-bound once at
-- CREATE POLICY time and only re-checks EXECUTE on the referenced function at each use, which is why
-- e.g. `vibetype_private.events_with_claimed_attendance()`, only ever called from `event_select`'s
-- policy, needs no such grant. tsquery_prefix() is called from a plain function body, not a policy.)
GRANT USAGE ON SCHEMA vibetype_private TO vibetype_account, vibetype_anonymous;

CREATE FUNCTION vibetype_private.tsquery_prefix(ts_config regconfig, search_text text) RETURNS tsquery
    LANGUAGE sql STABLE STRICT
    AS $$
  -- Builds an AND of prefix-matched lexemes (e.g. 'conc:*') so the last, possibly incomplete,
  -- word of a live-typed query matches by prefix instead of requiring a full word.
  SELECT COALESCE(
    string_agg(lexeme || ':*', ' & ')::tsquery,
    ''::tsquery
  )
  FROM unnest(tsvector_to_array(to_tsvector(tsquery_prefix.ts_config, tsquery_prefix.search_text))) AS lexeme;
$$;

COMMENT ON FUNCTION vibetype_private.tsquery_prefix(regconfig, TEXT) IS 'Converts free text into a prefix-matching tsquery for the given text search configuration.';

GRANT EXECUTE ON FUNCTION vibetype_private.tsquery_prefix(regconfig, TEXT) TO vibetype_account, vibetype_anonymous;

CREATE FUNCTION vibetype.event_search(query text) RETURNS SETOF vibetype.event
    LANGUAGE sql STABLE
    AS $$
  -- Tried across every language `search_vector` is merged from, so the caller does not need to know
  -- (or guess) which language a given event was authored in; see `table_event`'s search_vector trigger,
  -- which derives its language list dynamically. This list is kept static (not derived the same way)
  -- since this function runs on every search request, and there's no built-in aggregate to OR together
  -- a dynamic number of tsqueries; revisit if more real (non-'simple') configurations are added.
  WITH q AS (
    SELECT
      vibetype_private.tsquery_prefix('german', event_search.query)
      || vibetype_private.tsquery_prefix('english', event_search.query)
      || vibetype_private.tsquery_prefix('simple', event_search.query)
      AS tsquery
  )
  SELECT e.*
  FROM vibetype.event e, q
  WHERE
    e.search_vector @@ q.tsquery
    OR e.name % event_search.query
  ORDER BY
    GREATEST(
      ts_rank_cd(e.search_vector, q.tsquery),
      similarity(e.name, event_search.query)
    ) DESC
  LIMIT 50;
$$;

COMMENT ON FUNCTION vibetype.event_search(TEXT) IS 'Searches events by name and description. Matches by prefix so partial words match as the user types, and falls back to trigram similarity on the name for typo tolerance. Returns at most 50 events ordered by relevance.';

GRANT EXECUTE ON FUNCTION similarity(TEXT, TEXT) TO vibetype_account, vibetype_anonymous;
GRANT EXECUTE ON FUNCTION similarity_op(TEXT, TEXT) TO vibetype_account, vibetype_anonymous;
GRANT EXECUTE ON FUNCTION vibetype.event_search(TEXT) TO vibetype_account, vibetype_anonymous;

COMMIT;
