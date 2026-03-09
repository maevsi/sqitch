-- Benchmark queries for measuring database query performance.
-- Each query runs under both vibetype_anonymous and vibetype_account roles.
-- Outputs one JSON array to stdout with all timing results.
--
-- Each measurement discards the first (cold-cache) execution, then runs
-- the query repeatedly within a 5-second time budget and reports the median.

\pset format unaligned
\pset tuples_only on

-- Suppress intermediate output.
\o /dev/null

-- Reduce variance: disable JIT compilation and synchronized sequential scans.
SET jit = off;
SET synchronize_seqscans = off;

-- Warm up shared buffers.
SELECT count(*) FROM vibetype.account;
SELECT count(*) FROM vibetype.event;
SELECT count(*) FROM vibetype.guest;
SELECT count(*) FROM vibetype.contact;

-- Runs a query repeatedly within a time budget and returns the median timing as JSON.
-- The first execution is discarded (warm-up: plan compilation, buffer loading).
CREATE FUNCTION vibetype_test.benchmark_measure(
  query_name TEXT,
  role_label TEXT,
  query_sql TEXT
) RETURNS JSONB
    LANGUAGE plpgsql SECURITY INVOKER
    AS $$
DECLARE
  _start TIMESTAMPTZ;
  _end TIMESTAMPTZ;
  _timings NUMERIC[] := ARRAY[]::NUMERIC[];
  _budget_start TIMESTAMPTZ;
  _budget_seconds CONSTANT NUMERIC := 5.0;
  _median NUMERIC;
BEGIN
  -- Warm-up run: plan compilation and buffer loading (timing discarded).
  BEGIN
    SET LOCAL statement_timeout TO '5s';
    EXECUTE query_sql;
    SET LOCAL statement_timeout TO '0';
  EXCEPTION
    WHEN query_canceled THEN
      RETURN jsonb_build_object('name', query_name, 'role', role_label, 'total_time_ms', -1);
    WHEN OTHERS THEN
      RETURN jsonb_build_object('name', query_name, 'role', role_label, 'total_time_ms', -2);
  END;

  -- Timed runs within the budget.
  _budget_start := clock_timestamp();
  SET LOCAL statement_timeout TO '30s';
  WHILE EXTRACT(EPOCH FROM (clock_timestamp() - _budget_start)) < _budget_seconds LOOP
    _start := clock_timestamp();
    EXECUTE query_sql;
    _end := clock_timestamp();
    _timings := array_append(_timings, EXTRACT(EPOCH FROM (_end - _start)) * 1000);
  END LOOP;
  SET LOCAL statement_timeout TO '0';

  -- Proper statistical median.
  SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY val) INTO _median
    FROM unnest(_timings) AS val;

  RETURN jsonb_build_object(
    'name', query_name,
    'role', role_label,
    'total_time_ms', round(_median::NUMERIC, 3)
  );
END;
$$;

GRANT EXECUTE ON FUNCTION vibetype_test.benchmark_measure(TEXT, TEXT, TEXT) TO vibetype_anonymous, vibetype_account;

-- Wrappers for private-schema functions that user roles need to benchmark.
-- Handle both UUID[] (current) and TABLE (base branch) return types.
CREATE FUNCTION vibetype_test.events_invited() RETURNS UUID[]
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  result UUID[];
BEGIN
  BEGIN
    result := vibetype_private.events_invited();
  EXCEPTION WHEN OTHERS THEN
    SELECT COALESCE(array_agg(event_id), ARRAY[]::UUID[]) INTO result
      FROM vibetype_private.events_invited();
  END;
  RETURN result;
END;
$$;

CREATE FUNCTION vibetype_test.account_block_ids() RETURNS UUID[]
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  result UUID[];
BEGIN
  BEGIN
    result := vibetype_private.account_block_ids();
  EXCEPTION WHEN OTHERS THEN
    SELECT COALESCE(array_agg(id), ARRAY[]::UUID[]) INTO result
      FROM vibetype_private.account_block_ids();
  END;
  RETURN result;
END;
$$;

GRANT EXECUTE ON FUNCTION vibetype_test.events_invited() TO vibetype_anonymous, vibetype_account;
GRANT EXECUTE ON FUNCTION vibetype_test.account_block_ids() TO vibetype_anonymous, vibetype_account;

-- Resolve benchmark IDs.
DO $$
DECLARE
  _account_id UUID;
  _event_id UUID;
BEGIN
  SELECT id INTO _account_id FROM vibetype.account WHERE username = 'benchmark-user-1';
  SELECT id INTO _event_id FROM vibetype.event WHERE slug = 'benchmark-event-1';
  PERFORM set_config('benchmark.account_id', _account_id::TEXT, false);
  PERFORM set_config('benchmark.event_id', _event_id::TEXT, false);
END $$;

-- Query definitions: (name, sql, anonymous_only, authenticated_only).
CREATE TABLE vibetype_test.benchmark_queries (
  name TEXT NOT NULL,
  query_sql TEXT NOT NULL,
  anonymous_only BOOLEAN NOT NULL DEFAULT FALSE,
  authenticated_only BOOLEAN NOT NULL DEFAULT FALSE
);

GRANT SELECT ON vibetype_test.benchmark_queries TO vibetype_anonymous, vibetype_account;

INSERT INTO vibetype_test.benchmark_queries (name, query_sql, authenticated_only) VALUES
  ('account_block_ids',          'SELECT vibetype_test.account_block_ids()',                                                           FALSE),
  ('account_search',             'SELECT * FROM vibetype.account_search(''benchmark'')',                                               TRUE),
  ('attendance_claim_array',     'SELECT vibetype.attendance_claim_array()',                                                           FALSE),
  ('event_guest_count_maximum',  'SELECT vibetype.event_guest_count_maximum(''' || current_setting('benchmark.event_id') || '''::UUID)', FALSE),
  ('event_search',               'SELECT * FROM vibetype.event_search(''benchmark'', ''en'')',                                         FALSE),
  ('events_invited',             'SELECT vibetype_test.events_invited()',                                                              FALSE),
  ('guest_claim_array',          'SELECT vibetype.guest_claim_array()',                                                                FALSE),
  ('guest_count',                'SELECT vibetype.guest_count(''' || current_setting('benchmark.event_id') || '''::UUID)',              FALSE),
  ('select_accounts',            'SELECT * FROM vibetype.account',                                                                     FALSE),
  ('select_attendance',          'SELECT * FROM vibetype.attendance',                                                                  FALSE),
  ('select_contacts',            'SELECT * FROM vibetype.contact',                                                                     FALSE),
  ('select_events',              'SELECT * FROM vibetype.event',                                                                       FALSE),
  ('select_guests',              'SELECT * FROM vibetype.guest',                                                                       FALSE);

-- Collect all results into a single array.
CREATE TABLE vibetype_test.benchmark_results (result JSONB);

GRANT INSERT ON vibetype_test.benchmark_results TO vibetype_anonymous, vibetype_account;

-- Anonymous benchmarks.
SET ROLE vibetype_anonymous;
SELECT set_config('jwt.claims.sub', '', false);

INSERT INTO vibetype_test.benchmark_results
  SELECT vibetype_test.benchmark_measure(q.name, 'vibetype_anonymous', q.query_sql)
  FROM vibetype_test.benchmark_queries q
  WHERE NOT q.authenticated_only
  ORDER BY q.name;

RESET ROLE;

-- Authenticated benchmarks.
SET ROLE vibetype_account;
SELECT set_config('jwt.claims.sub', current_setting('benchmark.account_id'), false);

INSERT INTO vibetype_test.benchmark_results
  SELECT vibetype_test.benchmark_measure(q.name, 'vibetype_account', q.query_sql)
  FROM vibetype_test.benchmark_queries q
  WHERE NOT q.anonymous_only
  ORDER BY q.name;

RESET ROLE;

-- Restore stdout for final output.
\o

-- Output all results as a single JSON array.
SELECT jsonb_agg(result ORDER BY result->>'name', result->>'role')
  FROM vibetype_test.benchmark_results;
