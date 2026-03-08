-- Benchmark queries for measuring database query performance.
-- Each query is run as both vibetype_anonymous and vibetype_account roles.
-- Output: JSON rows with query name, role, and execution time.
--
-- Role switching is done at the psql script level (not inside functions)
-- because SET ROLE cannot be used inside SECURITY DEFINER functions.
--
-- Each measurement runs the query 10 times in a loop and divides by 10
-- to get a per-execution time. This reduces noise from fast queries.

\pset format unaligned
\pset tuples_only on

-- Warm up shared buffers
SELECT count(*) FROM vibetype.account;
SELECT count(*) FROM vibetype.event;
SELECT count(*) FROM vibetype.guest;
SELECT count(*) FROM vibetype.contact;

-- Helper function: runs a query in a loop and returns timing as JSON.
-- SECURITY INVOKER so it executes under whatever role is currently set.
CREATE OR REPLACE FUNCTION vibetype_test.benchmark_run(
  _name TEXT,
  _role_label TEXT,
  _sql TEXT,
  _iterations INT DEFAULT 10
) RETURNS JSONB
    LANGUAGE plpgsql SECURITY INVOKER
    AS $$
DECLARE
  _start TIMESTAMPTZ;
  _end TIMESTAMPTZ;
  _elapsed_ms NUMERIC;
  _i INT;
  _dummy RECORD;
BEGIN
  -- Force plan cache by running once
  EXECUTE _sql INTO _dummy;

  _start := clock_timestamp();
  FOR _i IN 1.._iterations LOOP
    EXECUTE _sql;
  END LOOP;
  _end := clock_timestamp();

  _elapsed_ms := round((EXTRACT(EPOCH FROM (_end - _start)) * 1000 / _iterations)::NUMERIC, 3);

  RETURN jsonb_build_object(
    'name', _name,
    'role', _role_label,
    'execution_time_ms', _elapsed_ms,
    'total_time_ms', _elapsed_ms
  );
END;
$$;

GRANT EXECUTE ON FUNCTION vibetype_test.benchmark_run(TEXT, TEXT, TEXT, INT) TO vibetype_anonymous, vibetype_account;

-- Helper function: runs benchmark _runs times and returns median timing.
CREATE OR REPLACE FUNCTION vibetype_test.benchmark_median(
  _name TEXT,
  _role_label TEXT,
  _sql TEXT,
  _runs INT DEFAULT 11,
  _iterations INT DEFAULT 10
) RETURNS JSONB
    LANGUAGE plpgsql SECURITY INVOKER
    AS $$
DECLARE
  _results NUMERIC[] := ARRAY[]::NUMERIC[];
  _run JSONB;
  _i INT;
  _median_total NUMERIC;
BEGIN
  FOR _i IN 1.._runs LOOP
    _run := vibetype_test.benchmark_run(_name, _role_label, _sql, _iterations);
    _results := array_append(_results, (_run->>'total_time_ms')::NUMERIC);
  END LOOP;

  -- Sort and pick median
  SELECT val INTO _median_total
    FROM unnest(_results) AS val ORDER BY val
    LIMIT 1 OFFSET _runs / 2;

  RETURN jsonb_build_object(
    'name', _name,
    'role', _role_label,
    'execution_time_ms', round(_median_total, 3),
    'total_time_ms', round(_median_total, 3)
  );
END;
$$;

GRANT EXECUTE ON FUNCTION vibetype_test.benchmark_median(TEXT, TEXT, TEXT, INT, INT) TO vibetype_anonymous, vibetype_account;

-- Resolve the benchmark account and event IDs
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

\echo --- BEGIN BENCHMARK RESULTS ---

-- ============================================================
-- Anonymous role benchmarks
-- ============================================================
SET ROLE vibetype_anonymous;
SELECT set_config('jwt.claims.sub', '', false);

SELECT vibetype_test.benchmark_median('select_accounts', 'vibetype_anonymous', 'SELECT * FROM vibetype.account');
SELECT vibetype_test.benchmark_median('select_events', 'vibetype_anonymous', 'SELECT * FROM vibetype.event');
SELECT vibetype_test.benchmark_median('select_guests', 'vibetype_anonymous', 'SELECT * FROM vibetype.guest');
SELECT vibetype_test.benchmark_median('select_contacts', 'vibetype_anonymous', 'SELECT * FROM vibetype.contact');
SELECT vibetype_test.benchmark_median('select_attendance', 'vibetype_anonymous', 'SELECT * FROM vibetype.attendance');
SELECT vibetype_test.benchmark_median('event_search', 'vibetype_anonymous', 'SELECT * FROM vibetype.event_search(''benchmark'', ''en'')');
SELECT vibetype_test.benchmark_median('guest_count', 'vibetype_anonymous', 'SELECT vibetype.guest_count(''' || current_setting('benchmark.event_id') || '''::UUID)');
SELECT vibetype_test.benchmark_median('events_invited', 'vibetype_anonymous', 'SELECT * FROM vibetype_private.events_invited()');
SELECT vibetype_test.benchmark_median('guest_claim_array', 'vibetype_anonymous', 'SELECT vibetype.guest_claim_array()');
SELECT vibetype_test.benchmark_median('account_block_ids', 'vibetype_anonymous', 'SELECT * FROM vibetype_private.account_block_ids()');
SELECT vibetype_test.benchmark_median('attendance_claim_array', 'vibetype_anonymous', 'SELECT vibetype.attendance_claim_array()');
SELECT vibetype_test.benchmark_median('event_guest_count_maximum', 'vibetype_anonymous', 'SELECT vibetype.event_guest_count_maximum(''' || current_setting('benchmark.event_id') || '''::UUID)');

RESET ROLE;

-- ============================================================
-- Authenticated role benchmarks
-- ============================================================
SET ROLE vibetype_account;
SELECT set_config('jwt.claims.sub', current_setting('benchmark.account_id'), false);

SELECT vibetype_test.benchmark_median('select_accounts', 'vibetype_account', 'SELECT * FROM vibetype.account');
SELECT vibetype_test.benchmark_median('select_events', 'vibetype_account', 'SELECT * FROM vibetype.event');
SELECT vibetype_test.benchmark_median('select_guests', 'vibetype_account', 'SELECT * FROM vibetype.guest');
SELECT vibetype_test.benchmark_median('select_contacts', 'vibetype_account', 'SELECT * FROM vibetype.contact');
SELECT vibetype_test.benchmark_median('select_attendance', 'vibetype_account', 'SELECT * FROM vibetype.attendance');
SELECT vibetype_test.benchmark_median('account_search', 'vibetype_account', 'SELECT * FROM vibetype.account_search(''benchmark'')');
SELECT vibetype_test.benchmark_median('event_search', 'vibetype_account', 'SELECT * FROM vibetype.event_search(''benchmark'', ''en'')');
SELECT vibetype_test.benchmark_median('guest_count', 'vibetype_account', 'SELECT vibetype.guest_count(''' || current_setting('benchmark.event_id') || '''::UUID)');
SELECT vibetype_test.benchmark_median('events_invited', 'vibetype_account', 'SELECT * FROM vibetype_private.events_invited()');
SELECT vibetype_test.benchmark_median('guest_claim_array', 'vibetype_account', 'SELECT vibetype.guest_claim_array()');
SELECT vibetype_test.benchmark_median('account_block_ids', 'vibetype_account', 'SELECT * FROM vibetype_private.account_block_ids()');
SELECT vibetype_test.benchmark_median('attendance_claim_array', 'vibetype_account', 'SELECT vibetype.attendance_claim_array()');
SELECT vibetype_test.benchmark_median('event_guest_count_maximum', 'vibetype_account', 'SELECT vibetype.event_guest_count_maximum(''' || current_setting('benchmark.event_id') || '''::UUID)');

RESET ROLE;

\echo --- END BENCHMARK RESULTS ---
