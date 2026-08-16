BEGIN;

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

-- Lives in the public vibetype schema (not vibetype_private) so vibetype_account/vibetype_anonymous can
-- call it with a plain EXECUTE grant, without needing USAGE on vibetype_private, which would make every
-- other vibetype_private function already EXECUTE-granted to them (e.g. account_block_ids(), used in RLS
-- policies) directly callable too. @omit keeps it out of the GraphQL schema; it exists only for
-- event_search() below to call.
-- SECURITY DEFINER: runs against vibetype_private.event_search_vector, which application roles have no
-- grant on at all (see that table's migration). Only vibetype_account/vibetype_anonymous need EXECUTE on
-- this function itself; tsquery_prefix() above needs no direct grant to them since it is now only ever
-- called from here, running as this function's owner.
CREATE FUNCTION vibetype.event_search_rank(query text) RETURNS TABLE(event_id UUID, rank REAL)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  -- The WHERE clause below matches each row against a query-side tsquery built with that row's own
  -- ts_config, so every comparison stays a pure, single-language match (undiluted `ts_rank_cd` scoring;
  -- see table_event_search_vector's migration). Each `@@` branch uses a literal, call-time-constant
  -- config (not `esv.ts_config` itself) so the GIN index on search_vector stays usable per branch; the
  -- SELECT list's ts_rank_cd, evaluated only on rows that already passed that filter, can then safely use
  -- the row's actual esv.ts_config directly. The list of configs tried is static rather than derived the
  -- same way the vector-populating trigger does, since this runs on every search request and there is no
  -- built-in aggregate to OR together a dynamic number of tsqueries; revisit if more real (non-'simple')
  -- configurations are added.
  SELECT
    esv.event_id,
    MAX(ts_rank_cd(esv.search_vector, vibetype_private.tsquery_prefix(esv.ts_config, event_search_rank.query))) AS rank
  FROM vibetype_private.event_search_vector esv
  WHERE
    (esv.ts_config = 'german'::regconfig AND esv.search_vector @@ vibetype_private.tsquery_prefix('german', event_search_rank.query))
    OR (esv.ts_config = 'english'::regconfig AND esv.search_vector @@ vibetype_private.tsquery_prefix('english', event_search_rank.query))
    OR (esv.ts_config = 'simple'::regconfig AND esv.search_vector @@ vibetype_private.tsquery_prefix('simple', event_search_rank.query))
  GROUP BY esv.event_id;
$$;

COMMENT ON FUNCTION vibetype.event_search_rank(TEXT) IS E'@omit\nReturns event ids matching the given query by prefix, across every text search configuration event_search_vector rows are stored in, with their relevance rank.';

GRANT EXECUTE ON FUNCTION vibetype.event_search_rank(TEXT) TO vibetype_account, vibetype_anonymous;

CREATE FUNCTION vibetype.event_search(query text) RETURNS SETOF vibetype.event
    LANGUAGE sql STABLE
    AS $$
  -- Falls back to trigram similarity on the name for typo tolerance, alongside the prefix match from
  -- event_search_rank(). The caller does not need to know (or guess) which language a given event was
  -- authored in; see vibetype_private.event_search_vector and the trigger that populates it.
  SELECT e.*
  FROM vibetype.event e
  LEFT JOIN vibetype.event_search_rank(event_search.query) r ON r.event_id = e.id
  WHERE
    r.rank IS NOT NULL
    OR e.name % event_search.query
  ORDER BY
    GREATEST(COALESCE(r.rank, 0), similarity(e.name, event_search.query)) DESC
  LIMIT 50;
$$;

COMMENT ON FUNCTION vibetype.event_search(TEXT) IS 'Searches events by name and description. Matches by prefix so partial words match as the user types, and falls back to trigram similarity on the name for typo tolerance. Returns at most 50 events ordered by relevance.';

GRANT EXECUTE ON FUNCTION similarity(TEXT, TEXT) TO vibetype_account, vibetype_anonymous;
GRANT EXECUTE ON FUNCTION similarity_op(TEXT, TEXT) TO vibetype_account, vibetype_anonymous;
GRANT EXECUTE ON FUNCTION vibetype.event_search(TEXT) TO vibetype_account, vibetype_anonymous;

COMMIT;
