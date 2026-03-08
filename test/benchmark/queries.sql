-- Benchmark queries for measuring database query performance.
-- Each query is run as both vibetype_anonymous and vibetype_account roles.
-- Output: JSON rows with query name, role, planning time, and execution time.
--
-- Usage: psql -f queries.sql -v account_id='<uuid>'
--
-- The account_id variable should be set to a seeded account for authenticated queries.

\pset format unaligned
\pset tuples_only on

-- Warm up shared buffers
SELECT count(*) FROM vibetype.account;
SELECT count(*) FROM vibetype.event;

-- Helper function to run EXPLAIN ANALYZE and extract timing as JSON
CREATE OR REPLACE FUNCTION vibetype_test.benchmark_query(
  _name TEXT,
  _sql TEXT,
  _role TEXT,
  _account_id UUID DEFAULT NULL
) RETURNS JSONB
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  _plan_text TEXT;
  _plan JSONB;
  _planning_time NUMERIC;
  _execution_time NUMERIC;
BEGIN
  -- Set role context
  IF _role = 'vibetype_account' AND _account_id IS NOT NULL THEN
    PERFORM set_config('jwt.claims.sub', _account_id::TEXT, true);
    EXECUTE 'SET LOCAL ROLE = vibetype_account';
  ELSIF _role = 'vibetype_anonymous' THEN
    PERFORM set_config('jwt.claims.sub', '', true);
    EXECUTE 'SET LOCAL ROLE = vibetype_anonymous';
  END IF;

  -- Run EXPLAIN ANALYZE and capture the JSON plan
  EXECUTE 'EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) ' || _sql INTO _plan_text;
  _plan := _plan_text::JSONB;

  _planning_time := (_plan->0->>'Planning Time')::NUMERIC;
  _execution_time := (_plan->0->>'Execution Time')::NUMERIC;

  -- Reset role
  RESET ROLE;
  PERFORM set_config('jwt.claims.sub', '', true);

  RETURN jsonb_build_object(
    'name', _name,
    'role', _role,
    'planning_time_ms', round(_planning_time, 3),
    'execution_time_ms', round(_execution_time, 3),
    'total_time_ms', round(_planning_time + _execution_time, 3)
  );
END;
$$;

-- Run each benchmark query 3 times per role and take the median.
-- We collect all individual runs, then pick the middle value.
CREATE OR REPLACE FUNCTION vibetype_test.benchmark_median(
  _name TEXT,
  _sql TEXT,
  _role TEXT,
  _account_id UUID DEFAULT NULL,
  _runs INT DEFAULT 3
) RETURNS JSONB
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  _results NUMERIC[] := ARRAY[]::NUMERIC[];
  _planning_times NUMERIC[] := ARRAY[]::NUMERIC[];
  _run JSONB;
  _i INT;
  _median_total NUMERIC;
  _median_planning NUMERIC;
  _median_execution NUMERIC;
BEGIN
  FOR _i IN 1.._runs LOOP
    _run := vibetype_test.benchmark_query(_name, _sql, _role, _account_id);
    _results := array_append(_results, (_run->>'total_time_ms')::NUMERIC);
    _planning_times := array_append(_planning_times, (_run->>'planning_time_ms')::NUMERIC);
  END LOOP;

  -- Sort and pick median
  SELECT val INTO _median_total
    FROM unnest(_results) AS val ORDER BY val
    LIMIT 1 OFFSET _runs / 2;

  SELECT val INTO _median_planning
    FROM unnest(_planning_times) AS val ORDER BY val
    LIMIT 1 OFFSET _runs / 2;

  _median_execution := _median_total - _median_planning;

  RETURN jsonb_build_object(
    'name', _name,
    'role', _role,
    'planning_time_ms', round(_median_planning, 3),
    'execution_time_ms', round(_median_execution, 3),
    'total_time_ms', round(_median_total, 3)
  );
END;
$$;

-- Resolve the benchmark account
DO $$
DECLARE
  _account_id UUID;
BEGIN
  SELECT id INTO _account_id FROM vibetype.account WHERE username = 'benchmark-user-1';
  PERFORM set_config('benchmark.account_id', _account_id::TEXT, false);
END $$;

\echo --- BEGIN BENCHMARK RESULTS ---

-- 1. SELECT all accounts (tests account RLS policy)
SELECT vibetype_test.benchmark_median(
  'select_accounts', 'SELECT * FROM vibetype.account', 'vibetype_anonymous'
);
SELECT vibetype_test.benchmark_median(
  'select_accounts', 'SELECT * FROM vibetype.account', 'vibetype_account',
  current_setting('benchmark.account_id')::UUID
);

-- 2. SELECT all events (tests event RLS policy — most complex)
SELECT vibetype_test.benchmark_median(
  'select_events', 'SELECT * FROM vibetype.event', 'vibetype_anonymous'
);
SELECT vibetype_test.benchmark_median(
  'select_events', 'SELECT * FROM vibetype.event', 'vibetype_account',
  current_setting('benchmark.account_id')::UUID
);

-- 3. SELECT all guests (tests guest RLS policy)
SELECT vibetype_test.benchmark_median(
  'select_guests', 'SELECT * FROM vibetype.guest', 'vibetype_anonymous'
);
SELECT vibetype_test.benchmark_median(
  'select_guests', 'SELECT * FROM vibetype.guest', 'vibetype_account',
  current_setting('benchmark.account_id')::UUID
);

-- 4. Account search (trigram ILIKE)
SELECT vibetype_test.benchmark_median(
  'account_search', 'SELECT * FROM vibetype.account_search(''benchmark'')', 'vibetype_account',
  current_setting('benchmark.account_id')::UUID
);

-- 5. Event search (full-text search with tsvector)
SELECT vibetype_test.benchmark_median(
  'event_search', 'SELECT * FROM vibetype.event_search(''benchmark'', ''en'')', 'vibetype_anonymous'
);
SELECT vibetype_test.benchmark_median(
  'event_search', 'SELECT * FROM vibetype.event_search(''benchmark'', ''en'')', 'vibetype_account',
  current_setting('benchmark.account_id')::UUID
);

-- 6. Guest count for an event
DO $$
DECLARE
  _event_id UUID;
BEGIN
  SELECT id INTO _event_id FROM vibetype.event WHERE slug = 'benchmark-event-1';
  PERFORM set_config('benchmark.event_id', _event_id::TEXT, false);
END $$;

SELECT vibetype_test.benchmark_median(
  'guest_count', 'SELECT vibetype.guest_count(''' || current_setting('benchmark.event_id') || '''::UUID)', 'vibetype_anonymous'
);
SELECT vibetype_test.benchmark_median(
  'guest_count', 'SELECT vibetype.guest_count(''' || current_setting('benchmark.event_id') || '''::UUID)', 'vibetype_account',
  current_setting('benchmark.account_id')::UUID
);

-- 7. Events invited (complex RLS helper)
SELECT vibetype_test.benchmark_median(
  'events_invited', 'SELECT * FROM vibetype_private.events_invited()', 'vibetype_anonymous'
);
SELECT vibetype_test.benchmark_median(
  'events_invited', 'SELECT * FROM vibetype_private.events_invited()', 'vibetype_account',
  current_setting('benchmark.account_id')::UUID
);

-- 8. Guest claim array
SELECT vibetype_test.benchmark_median(
  'guest_claim_array', 'SELECT vibetype.guest_claim_array()', 'vibetype_anonymous'
);
SELECT vibetype_test.benchmark_median(
  'guest_claim_array', 'SELECT vibetype.guest_claim_array()', 'vibetype_account',
  current_setting('benchmark.account_id')::UUID
);

-- 9. Account block IDs
SELECT vibetype_test.benchmark_median(
  'account_block_ids', 'SELECT * FROM vibetype_private.account_block_ids()', 'vibetype_anonymous'
);
SELECT vibetype_test.benchmark_median(
  'account_block_ids', 'SELECT * FROM vibetype_private.account_block_ids()', 'vibetype_account',
  current_setting('benchmark.account_id')::UUID
);

-- 10. Attendance claim array
SELECT vibetype_test.benchmark_median(
  'attendance_claim_array', 'SELECT vibetype.attendance_claim_array()', 'vibetype_anonymous'
);
SELECT vibetype_test.benchmark_median(
  'attendance_claim_array', 'SELECT vibetype.attendance_claim_array()', 'vibetype_account',
  current_setting('benchmark.account_id')::UUID
);

-- 11. Event guest count maximum
SELECT vibetype_test.benchmark_median(
  'event_guest_count_maximum', 'SELECT vibetype.event_guest_count_maximum(''' || current_setting('benchmark.event_id') || '''::UUID)', 'vibetype_anonymous'
);
SELECT vibetype_test.benchmark_median(
  'event_guest_count_maximum', 'SELECT vibetype.event_guest_count_maximum(''' || current_setting('benchmark.event_id') || '''::UUID)', 'vibetype_account',
  current_setting('benchmark.account_id')::UUID
);

-- 12. SELECT contacts (tests contact RLS policy)
SELECT vibetype_test.benchmark_median(
  'select_contacts', 'SELECT * FROM vibetype.contact', 'vibetype_anonymous'
);
SELECT vibetype_test.benchmark_median(
  'select_contacts', 'SELECT * FROM vibetype.contact', 'vibetype_account',
  current_setting('benchmark.account_id')::UUID
);

-- 13. SELECT attendance (tests attendance RLS policy)
SELECT vibetype_test.benchmark_median(
  'select_attendance', 'SELECT * FROM vibetype.attendance', 'vibetype_anonymous'
);
SELECT vibetype_test.benchmark_median(
  'select_attendance', 'SELECT * FROM vibetype.attendance', 'vibetype_account',
  current_setting('benchmark.account_id')::UUID
);

\echo --- END BENCHMARK RESULTS ---
