-- Benchmark queries for measuring database query performance.
-- Each query is run as both vibetype_anonymous and vibetype_account roles.
-- Output: JSON rows with query name, role, and execution time.
--
-- Role switching is done at the psql script level (not inside functions)
-- because SET ROLE cannot be used inside SECURITY DEFINER functions.
--
-- Each measurement auto-selects an iteration count targeting ~500ms of
-- wall time, then divides by iteration count for per-execution timing.

\pset format unaligned
\pset tuples_only on

-- Warm up shared buffers
\echo [benchmark] warming up shared buffers...
SELECT count(*) FROM vibetype.account;
SELECT count(*) FROM vibetype.event;
SELECT count(*) FROM vibetype.guest;
SELECT count(*) FROM vibetype.contact;
\echo [benchmark] warmup complete

-- Helper function: runs a query in a loop and returns per-iteration timing as JSON.
-- Automatically picks iteration count to target ~500ms of wall time per measurement.
-- If a single execution takes > 1s, skips the loop and returns the warmup timing.
-- Times out after 10s and returns -1 for timed-out queries.
-- SECURITY INVOKER so it executes under whatever role is currently set.
CREATE OR REPLACE FUNCTION vibetype_test.benchmark_run(
  _name TEXT,
  _role_label TEXT,
  _sql TEXT
) RETURNS JSONB
    LANGUAGE plpgsql SECURITY INVOKER
    AS $$
DECLARE
  _start TIMESTAMPTZ;
  _end TIMESTAMPTZ;
  _warmup_ms NUMERIC;
  _iterations INT;
  _elapsed_ms NUMERIC;
  _i INT;
BEGIN
  -- Warmup with 10-second timeout
  BEGIN
    EXECUTE 'SET LOCAL statement_timeout = ''10s''';
    _start := clock_timestamp();
    EXECUTE _sql;
    _end := clock_timestamp();
    EXECUTE 'SET LOCAL statement_timeout = ''0''';
  EXCEPTION WHEN OTHERS THEN
    -- Query timed out or failed (e.g. permission denied)
    RAISE NOTICE '[benchmark] skipped: % as % - %', _name, _role_label, SQLERRM;
    RETURN jsonb_build_object(
      'name', _name,
      'role', _role_label,
      'execution_time_ms', -1,
      'total_time_ms', -1
    );
  END;

  _warmup_ms := EXTRACT(EPOCH FROM (_end - _start)) * 1000;

  -- For slow queries (> 1s), just return the warmup timing directly
  IF _warmup_ms > 1000 THEN
    RETURN jsonb_build_object(
      'name', _name,
      'role', _role_label,
      'execution_time_ms', round(_warmup_ms::NUMERIC, 3),
      'total_time_ms', round(_warmup_ms::NUMERIC, 3)
    );
  END IF;

  -- Target ~500ms total: fast queries get many iterations, slow ones get fewer
  _iterations := GREATEST(1, LEAST(100, floor(500.0 / GREATEST(_warmup_ms, 0.01))));

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

GRANT EXECUTE ON FUNCTION vibetype_test.benchmark_run(TEXT, TEXT, TEXT) TO vibetype_anonymous, vibetype_account;
\echo [benchmark] benchmark_run function created

-- Helper function: runs benchmark multiple times and returns median timing.
-- Adapts run count: 11 for fast queries, 3 for slow ones (> 1s).
-- Enforces a 60-second time budget per query.
CREATE OR REPLACE FUNCTION vibetype_test.benchmark_median(
  _name TEXT,
  _role_label TEXT,
  _sql TEXT,
  _runs INT DEFAULT 11
) RETURNS JSONB
    LANGUAGE plpgsql SECURITY INVOKER
    AS $$
DECLARE
  _results NUMERIC[] := ARRAY[]::NUMERIC[];
  _run JSONB;
  _i INT := 0;
  _actual_runs INT;
  _median_total NUMERIC;
  _budget_start TIMESTAMPTZ := clock_timestamp();
BEGIN
  _actual_runs := _runs;

  WHILE _i < _actual_runs LOOP
    _i := _i + 1;
    _run := vibetype_test.benchmark_run(_name, _role_label, _sql);
    _results := array_append(_results, (_run->>'total_time_ms')::NUMERIC);

    -- After first run: reduce to 3 runs if query is slow (> 1s)
    IF _i = 1 AND (_run->>'total_time_ms')::NUMERIC > 1000 THEN
      _actual_runs := 3;
    END IF;

    -- Enforce 60-second time budget
    IF EXTRACT(EPOCH FROM (clock_timestamp() - _budget_start)) > 60 THEN
      EXIT;
    END IF;
  END LOOP;

  -- Sort and pick median
  SELECT val INTO _median_total
    FROM unnest(_results) AS val ORDER BY val
    LIMIT 1 OFFSET array_length(_results, 1) / 2;

  RETURN jsonb_build_object(
    'name', _name,
    'role', _role_label,
    'execution_time_ms', round(_median_total, 3),
    'total_time_ms', round(_median_total, 3)
  );
END;
$$;

GRANT EXECUTE ON FUNCTION vibetype_test.benchmark_median(TEXT, TEXT, TEXT, INT) TO vibetype_anonymous, vibetype_account;
\echo [benchmark] benchmark_median function created

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
\echo [benchmark] account/event IDs resolved

\echo --- BEGIN BENCHMARK RESULTS ---

-- ============================================================
-- Anonymous role benchmarks
-- ============================================================
SET ROLE vibetype_anonymous;
SELECT set_config('jwt.claims.sub', '', false);
\echo [benchmark] starting anonymous benchmarks...

\echo [benchmark] anon: select_accounts
SELECT vibetype_test.benchmark_median('select_accounts', 'vibetype_anonymous', 'SELECT * FROM vibetype.account');
\echo [benchmark] anon: select_events
SELECT vibetype_test.benchmark_median('select_events', 'vibetype_anonymous', 'SELECT * FROM vibetype.event');
\echo [benchmark] anon: select_guests
SELECT vibetype_test.benchmark_median('select_guests', 'vibetype_anonymous', 'SELECT * FROM vibetype.guest');
\echo [benchmark] anon: select_contacts
SELECT vibetype_test.benchmark_median('select_contacts', 'vibetype_anonymous', 'SELECT * FROM vibetype.contact');
\echo [benchmark] anon: select_attendance
SELECT vibetype_test.benchmark_median('select_attendance', 'vibetype_anonymous', 'SELECT * FROM vibetype.attendance');
\echo [benchmark] anon: event_search
SELECT vibetype_test.benchmark_median('event_search', 'vibetype_anonymous', 'SELECT * FROM vibetype.event_search(''benchmark'', ''en'')');
\echo [benchmark] anon: guest_count
SELECT vibetype_test.benchmark_median('guest_count', 'vibetype_anonymous', 'SELECT vibetype.guest_count(''' || current_setting('benchmark.event_id') || '''::UUID)');
\echo [benchmark] anon: guest_claim_array
SELECT vibetype_test.benchmark_median('guest_claim_array', 'vibetype_anonymous', 'SELECT vibetype.guest_claim_array()');
\echo [benchmark] anon: attendance_claim_array
SELECT vibetype_test.benchmark_median('attendance_claim_array', 'vibetype_anonymous', 'SELECT vibetype.attendance_claim_array()');
\echo [benchmark] anon: event_guest_count_maximum
SELECT vibetype_test.benchmark_median('event_guest_count_maximum', 'vibetype_anonymous', 'SELECT vibetype.event_guest_count_maximum(''' || current_setting('benchmark.event_id') || '''::UUID)');

RESET ROLE;
\echo [benchmark] anonymous benchmarks complete

-- ============================================================
-- Authenticated role benchmarks
-- ============================================================
SET ROLE vibetype_account;
SELECT set_config('jwt.claims.sub', current_setting('benchmark.account_id'), false);
\echo [benchmark] starting authenticated benchmarks...

\echo [benchmark] auth: select_accounts
SELECT vibetype_test.benchmark_median('select_accounts', 'vibetype_account', 'SELECT * FROM vibetype.account');
\echo [benchmark] auth: select_events
SELECT vibetype_test.benchmark_median('select_events', 'vibetype_account', 'SELECT * FROM vibetype.event');
\echo [benchmark] auth: select_guests
SELECT vibetype_test.benchmark_median('select_guests', 'vibetype_account', 'SELECT * FROM vibetype.guest');
\echo [benchmark] auth: select_contacts
SELECT vibetype_test.benchmark_median('select_contacts', 'vibetype_account', 'SELECT * FROM vibetype.contact');
\echo [benchmark] auth: select_attendance
SELECT vibetype_test.benchmark_median('select_attendance', 'vibetype_account', 'SELECT * FROM vibetype.attendance');
\echo [benchmark] auth: account_search
SELECT vibetype_test.benchmark_median('account_search', 'vibetype_account', 'SELECT * FROM vibetype.account_search(''benchmark'')');
\echo [benchmark] auth: event_search
SELECT vibetype_test.benchmark_median('event_search', 'vibetype_account', 'SELECT * FROM vibetype.event_search(''benchmark'', ''en'')');
\echo [benchmark] auth: guest_count
SELECT vibetype_test.benchmark_median('guest_count', 'vibetype_account', 'SELECT vibetype.guest_count(''' || current_setting('benchmark.event_id') || '''::UUID)');
\echo [benchmark] auth: events_invited
SELECT vibetype_test.benchmark_median('events_invited', 'vibetype_account', 'SELECT * FROM vibetype_private.events_invited()');
\echo [benchmark] auth: guest_claim_array
SELECT vibetype_test.benchmark_median('guest_claim_array', 'vibetype_account', 'SELECT vibetype.guest_claim_array()');
\echo [benchmark] auth: account_block_ids
SELECT vibetype_test.benchmark_median('account_block_ids', 'vibetype_account', 'SELECT * FROM vibetype_private.account_block_ids()');
\echo [benchmark] auth: attendance_claim_array
SELECT vibetype_test.benchmark_median('attendance_claim_array', 'vibetype_account', 'SELECT vibetype.attendance_claim_array()');
\echo [benchmark] auth: event_guest_count_maximum
SELECT vibetype_test.benchmark_median('event_guest_count_maximum', 'vibetype_account', 'SELECT vibetype.event_guest_count_maximum(''' || current_setting('benchmark.event_id') || '''::UUID)');

RESET ROLE;
\echo [benchmark] authenticated benchmarks complete
\echo --- END BENCHMARK RESULTS ---
