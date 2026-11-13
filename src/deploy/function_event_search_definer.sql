BEGIN;

CREATE OR REPLACE FUNCTION vibetype.event_search_rank(query text) RETURNS TABLE(event_id UUID, rank REAL)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
  -- Each text search configuration's tsquery is built once per call in a materialized CTE, not per row.
  -- The `@@` condition on the tsquery column of the CTE row stays a parameterized GIN index condition on search_vector inside the nested loop; the ts_config equality then only filters the rows the index returned, instead of scanning the whole primary key.
  -- The list of configs tried is static rather than derived the same way the vector-populating trigger does; revisit if more (non-'simple') configurations are added, and keep event_search_rank_configs_covered's test in sync.
  WITH _q AS MATERIALIZED (
    SELECT
      c.ts_config,
      vibetype_private.tsquery_prefix(c.ts_config, event_search_rank.query) AS tsquery
    FROM (VALUES ('german'::regconfig), ('english'::regconfig), ('simple'::regconfig)) AS c(ts_config)
  )
  SELECT
    esv.event_id,
    MAX(ts_rank_cd(esv.search_vector, _q.tsquery)) AS rank
  FROM _q
  JOIN vibetype_private.event_search_vector esv
    ON esv.search_vector @@ _q.tsquery
    AND esv.ts_config = _q.ts_config
  GROUP BY esv.event_id;
$$;

-- Lives in the vibetype schema so vibetype_account can call it with a plain EXECUTE grant; @behavior -* keeps it out of the GraphQL schema.
-- SECURITY DEFINER: the trigram match on the event name runs as the owner, so the non-leakproof `%` operator is not gated behind the event row level security policies and idx_event_name_trgm becomes usable.
-- It returns ids and scores only, and event_search() joins vibetype.event by primary key, so the policies apply to the candidate rows and drop every event the invoker may not see, together with its score.
-- Like event_search_rank(), it can be called directly and then reveals the ids and relevance of matching events regardless of visibility; there is no cheap way to mirror the event policies here without defeating the purpose.
CREATE FUNCTION vibetype.event_search_match(query text) RETURNS TABLE(event_id UUID, score REAL)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
  -- The two candidate sources are combined with UNION ALL, not an OR condition, so each can use its own index.
  WITH _candidate AS (
    SELECT r.event_id, r.rank FROM vibetype.event_search_rank(event_search_match.query) r
    UNION ALL
    SELECT e.id, 0::REAL FROM vibetype.event e WHERE e.name % event_search_match.query
  ),
  _best AS (
    SELECT event_id, MAX(rank) AS rank FROM _candidate GROUP BY event_id
  )
  SELECT
    e.id,
    GREATEST(b.rank, similarity(e.name, event_search_match.query))
  FROM _best b
  JOIN vibetype.event e ON e.id = b.event_id;
$$;

COMMENT ON FUNCTION vibetype.event_search_match(TEXT) IS E'@behavior -*\nReturns ids of events matching the given query by prefix or by name trigram similarity, with their relevance score.';

REVOKE ALL ON FUNCTION vibetype.event_search_match(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION vibetype.event_search_match(TEXT) TO vibetype_account;

CREATE OR REPLACE FUNCTION vibetype.event_search(query text) RETURNS SETOF vibetype.event
    LANGUAGE sql STABLE
    AS $$
  -- Falls back to trigram similarity on the name for typo tolerance, alongside the prefix match from event_search_rank().
  -- The caller does not need to know (or guess) which language a given event was authored in; see vibetype_private.event_search_vector and the trigger that populates it.
  SELECT e.*
  FROM vibetype.event_search_match(event_search.query) m
  JOIN vibetype.event e ON e.id = m.event_id
  ORDER BY
    m.score DESC,
    e.id;
$$;

COMMIT;
