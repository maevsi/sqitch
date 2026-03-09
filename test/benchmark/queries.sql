-- Benchmark queries for measuring database query performance.
-- Each query is run as both vibetype_anonymous and vibetype_account roles.
-- Output: JSON rows with query name, role, and total execution time.
--
-- Role switching is done at the psql script level (not inside functions)
-- because SET ROLE cannot be used inside SECURITY DEFINER functions.
--
-- Each measurement runs the query repeatedly within a 5-second time budget
-- and returns the median per-execution timing.

\pset format unaligned
\pset tuples_only on

-- Warm up shared buffers
\echo [benchmark] warming up shared buffers...
SELECT count(*) FROM vibetype.account;
SELECT count(*) FROM vibetype.event;
SELECT count(*) FROM vibetype.guest;
SELECT count(*) FROM vibetype.contact;
\echo [benchmark] warmup complete

-- Runs a query repeatedly within a 5-second time budget and returns the median
-- per-execution timing as JSON.
-- Returns -1 on timeout (first run exceeds 5s), -2 on any other error.
-- SECURITY INVOKER so it executes under whatever role is currently set.
CREATE OR REPLACE FUNCTION vibetype_test.benchmark_query(
  _name TEXT,
  _role_label TEXT,
  _sql TEXT
) RETURNS JSONB
    LANGUAGE plpgsql SECURITY INVOKER
    AS $$
DECLARE
  _start TIMESTAMPTZ;
  _end TIMESTAMPTZ;
  _timings NUMERIC[] := ARRAY[]::NUMERIC[];
  _budget_start TIMESTAMPTZ := clock_timestamp();
  _budget_s CONSTANT NUMERIC := 5.0;
  _median NUMERIC;
BEGIN
  -- First run: detect timeout/error
  BEGIN
    SET LOCAL statement_timeout TO '5s';
    _start := clock_timestamp();
    EXECUTE _sql;
    _end := clock_timestamp();
    SET LOCAL statement_timeout TO '0';
  EXCEPTION
    WHEN query_canceled THEN
      RAISE NOTICE '[benchmark] timeout: % as %', _name, _role_label;
      RETURN jsonb_build_object('name', _name, 'role', _role_label, 'total_time_ms', -1);
    WHEN OTHERS THEN
      RAISE NOTICE '[benchmark] error: % as % - %', _name, _role_label, SQLERRM;
      RETURN jsonb_build_object('name', _name, 'role', _role_label, 'total_time_ms', -2);
  END;

  _timings := array_append(_timings, EXTRACT(EPOCH FROM (_end - _start)) * 1000);

  -- Continue running until the time budget is exhausted
  SET LOCAL statement_timeout TO '30s';
  WHILE EXTRACT(EPOCH FROM (clock_timestamp() - _budget_start)) < _budget_s LOOP
    _start := clock_timestamp();
    EXECUTE _sql;
    _end := clock_timestamp();
    _timings := array_append(_timings, EXTRACT(EPOCH FROM (_end - _start)) * 1000);
  END LOOP;
  SET LOCAL statement_timeout TO '0';

  SELECT val INTO _median
    FROM unnest(_timings) AS val ORDER BY val
    LIMIT 1 OFFSET array_length(_timings, 1) / 2;

  RETURN jsonb_build_object(
    'name', _name,
    'role', _role_label,
    'total_time_ms', round(_median::NUMERIC, 3)
  );
END;
$$;

GRANT EXECUTE ON FUNCTION vibetype_test.benchmark_query(TEXT, TEXT, TEXT) TO vibetype_anonymous, vibetype_account;
\echo [benchmark] benchmark_query function created

-- Wrapper for vibetype_private.events_invited() accessible to benchmark roles.
-- The original function is SECURITY DEFINER in vibetype_private (no USAGE grant
-- for user roles), but user roles have EXECUTE on it. This SECURITY DEFINER
-- wrapper allows the benchmark SECURITY INVOKER functions to call it.
CREATE OR REPLACE FUNCTION vibetype_test.events_invited()
  RETURNS UUID[]
    LANGUAGE sql SECURITY DEFINER
    AS $$
  SELECT vibetype_private.events_invited();
$$;

GRANT EXECUTE ON FUNCTION vibetype_test.events_invited() TO vibetype_anonymous, vibetype_account;

-- Wrapper for vibetype_private.account_block_ids()
CREATE OR REPLACE FUNCTION vibetype_test.account_block_ids()
  RETURNS UUID[]
    LANGUAGE sql SECURITY DEFINER
    AS $$
  SELECT vibetype_private.account_block_ids();
$$;

GRANT EXECUTE ON FUNCTION vibetype_test.account_block_ids() TO vibetype_anonymous, vibetype_account;
\echo [benchmark] wrapper functions created

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

\echo [benchmark] anon: account_block_ids
SELECT vibetype_test.benchmark_query('account_block_ids', 'vibetype_anonymous', 'SELECT vibetype_test.account_block_ids()');
\echo [benchmark] anon: attendance_claim_array
SELECT vibetype_test.benchmark_query('attendance_claim_array', 'vibetype_anonymous', 'SELECT vibetype.attendance_claim_array()');
\echo [benchmark] anon: event_guest_count_maximum
SELECT vibetype_test.benchmark_query('event_guest_count_maximum', 'vibetype_anonymous', 'SELECT vibetype.event_guest_count_maximum(''' || current_setting('benchmark.event_id') || '''::UUID)');
\echo [benchmark] anon: event_search
SELECT vibetype_test.benchmark_query('event_search', 'vibetype_anonymous', 'SELECT * FROM vibetype.event_search(''benchmark'', ''en'')');
\echo [benchmark] anon: events_invited
SELECT vibetype_test.benchmark_query('events_invited', 'vibetype_anonymous', 'SELECT vibetype_test.events_invited()');
\echo [benchmark] anon: guest_claim_array
SELECT vibetype_test.benchmark_query('guest_claim_array', 'vibetype_anonymous', 'SELECT vibetype.guest_claim_array()');
\echo [benchmark] anon: guest_count
SELECT vibetype_test.benchmark_query('guest_count', 'vibetype_anonymous', 'SELECT vibetype.guest_count(''' || current_setting('benchmark.event_id') || '''::UUID)');
\echo [benchmark] anon: select_accounts
SELECT vibetype_test.benchmark_query('select_accounts', 'vibetype_anonymous', 'SELECT * FROM vibetype.account');
\echo [benchmark] anon: select_attendance
SELECT vibetype_test.benchmark_query('select_attendance', 'vibetype_anonymous', 'SELECT * FROM vibetype.attendance');
\echo [benchmark] anon: select_contacts
SELECT vibetype_test.benchmark_query('select_contacts', 'vibetype_anonymous', 'SELECT * FROM vibetype.contact');
\echo [benchmark] anon: select_events
SELECT vibetype_test.benchmark_query('select_events', 'vibetype_anonymous', 'SELECT * FROM vibetype.event');
\echo [benchmark] anon: select_guests
SELECT vibetype_test.benchmark_query('select_guests', 'vibetype_anonymous', 'SELECT * FROM vibetype.guest');

RESET ROLE;
\echo [benchmark] anonymous benchmarks complete

-- ============================================================
-- Authenticated role benchmarks
-- ============================================================
SET ROLE vibetype_account;
SELECT set_config('jwt.claims.sub', current_setting('benchmark.account_id'), false);
\echo [benchmark] starting authenticated benchmarks...

\echo [benchmark] auth: account_block_ids
SELECT vibetype_test.benchmark_query('account_block_ids', 'vibetype_account', 'SELECT vibetype_test.account_block_ids()');
\echo [benchmark] auth: account_search
SELECT vibetype_test.benchmark_query('account_search', 'vibetype_account', 'SELECT * FROM vibetype.account_search(''benchmark'')');
\echo [benchmark] auth: attendance_claim_array
SELECT vibetype_test.benchmark_query('attendance_claim_array', 'vibetype_account', 'SELECT vibetype.attendance_claim_array()');
\echo [benchmark] auth: event_guest_count_maximum
SELECT vibetype_test.benchmark_query('event_guest_count_maximum', 'vibetype_account', 'SELECT vibetype.event_guest_count_maximum(''' || current_setting('benchmark.event_id') || '''::UUID)');
\echo [benchmark] auth: event_search
SELECT vibetype_test.benchmark_query('event_search', 'vibetype_account', 'SELECT * FROM vibetype.event_search(''benchmark'', ''en'')');
\echo [benchmark] auth: events_invited
SELECT vibetype_test.benchmark_query('events_invited', 'vibetype_account', 'SELECT vibetype_test.events_invited()');
\echo [benchmark] auth: guest_claim_array
SELECT vibetype_test.benchmark_query('guest_claim_array', 'vibetype_account', 'SELECT vibetype.guest_claim_array()');
\echo [benchmark] auth: guest_count
SELECT vibetype_test.benchmark_query('guest_count', 'vibetype_account', 'SELECT vibetype.guest_count(''' || current_setting('benchmark.event_id') || '''::UUID)');
\echo [benchmark] auth: select_accounts
SELECT vibetype_test.benchmark_query('select_accounts', 'vibetype_account', 'SELECT * FROM vibetype.account');
\echo [benchmark] auth: select_attendance
SELECT vibetype_test.benchmark_query('select_attendance', 'vibetype_account', 'SELECT * FROM vibetype.attendance');
\echo [benchmark] auth: select_contacts
SELECT vibetype_test.benchmark_query('select_contacts', 'vibetype_account', 'SELECT * FROM vibetype.contact');
\echo [benchmark] auth: select_events
SELECT vibetype_test.benchmark_query('select_events', 'vibetype_account', 'SELECT * FROM vibetype.event');
\echo [benchmark] auth: select_guests
SELECT vibetype_test.benchmark_query('select_guests', 'vibetype_account', 'SELECT * FROM vibetype.guest');

RESET ROLE;
\echo [benchmark] authenticated benchmarks complete
\echo --- END BENCHMARK RESULTS ---
