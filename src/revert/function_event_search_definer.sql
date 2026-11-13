BEGIN;

CREATE OR REPLACE FUNCTION vibetype.event_search(query text) RETURNS SETOF vibetype.event
    LANGUAGE sql STABLE
    AS $$
  -- Falls back to trigram similarity on the name for typo tolerance, alongside the prefix match from event_search_rank().
  -- The caller does not need to know (or guess) which language a given event was authored in; see vibetype_private.event_search_vector and the trigger that populates it.
  SELECT e.*
  FROM vibetype.event e
  LEFT JOIN vibetype.event_search_rank(event_search.query) r ON r.event_id = e.id
  WHERE
    r.rank IS NOT NULL
    OR e.name % event_search.query
  ORDER BY
    GREATEST(COALESCE(r.rank, 0), similarity(e.name, event_search.query)) DESC,
    e.id;
$$;

DROP FUNCTION vibetype.event_search_match(TEXT);

CREATE OR REPLACE FUNCTION vibetype.event_search_rank(query text) RETURNS TABLE(event_id UUID, rank REAL)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
  -- The WHERE clause below matches each row against a query-side tsquery built with that row's own ts_config, so every comparison stays a pure, single-language match (undiluted `ts_rank_cd` scoring; see table_event_search_vector's migration).
  -- Each `@@` branch uses a literal, call-time-constant config (not `esv.ts_config` itself) so the GIN index on search_vector stays usable per branch; the SELECT list's ts_rank_cd, evaluated only on rows that already passed that filter, can then safely use the row's actual esv.ts_config directly.
  -- The list of configs tried is static rather than derived the same way the vector-populating trigger does, since this runs on every search request and there is no built-in aggregate to OR together a dynamic number of tsqueries; revisit if more real (non-'simple') configurations are added.
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

COMMIT;
