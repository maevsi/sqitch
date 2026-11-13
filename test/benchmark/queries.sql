-- Benchmark queries for measuring database query performance.
-- Each query runs under both vibetype_anonymous and vibetype_account roles.
-- A subset of the queries additionally runs as each skewed persona seeded at the
-- end of seed.sql, as vibetype_account only, named `<query>@<persona>`.
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
    BEGIN
      _start := clock_timestamp();
      EXECUTE query_sql;
      _end := clock_timestamp();
      _timings := array_append(_timings, EXTRACT(EPOCH FROM (_end - _start)) * 1000);
    EXCEPTION
      WHEN query_canceled THEN
        RETURN jsonb_build_object('name', query_name, 'role', role_label, 'total_time_ms', -1);
      WHEN OTHERS THEN
        RETURN jsonb_build_object('name', query_name, 'role', role_label, 'total_time_ms', -2);
    END;
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

-- vibetype_anonymous/vibetype_account have no USAGE on vibetype_private, so these
-- private-schema functions need a security definer proxy to be benchmarkable at all.
CREATE FUNCTION vibetype_test.account_block_ids() RETURNS UUID[]
    LANGUAGE sql SECURITY DEFINER
    AS $$
  SELECT vibetype_private.account_block_ids();
$$;

CREATE FUNCTION vibetype_test.events_invited() RETURNS UUID[]
    LANGUAGE sql SECURITY DEFINER
    AS $$
  SELECT vibetype_private.events_invited();
$$;

GRANT EXECUTE ON FUNCTION vibetype_test.account_block_ids() TO vibetype_anonymous, vibetype_account;
GRANT EXECUTE ON FUNCTION vibetype_test.events_invited() TO vibetype_anonymous, vibetype_account;

-- Personas: the default persona (empty label) keeps the plain query names.
-- Queries reference its ids through the {account_id}, {attendance_id} and {event_id} placeholders.
CREATE TABLE vibetype_test.benchmark_personas (
  label TEXT NOT NULL,
  account_id UUID NOT NULL,
  attendance_id UUID,
  event_id UUID NOT NULL
);

GRANT SELECT ON vibetype_test.benchmark_personas TO vibetype_anonymous, vibetype_account;

INSERT INTO vibetype_test.benchmark_personas (label, account_id, attendance_id, event_id)
  SELECT
    '',
    a.id,
    (SELECT at.id
      FROM vibetype.attendance at
      JOIN vibetype.guest g ON g.id = at.guest_id
      JOIN vibetype.event e ON e.id = g.event_id
      WHERE e.created_by = a.id
      ORDER BY at.id
      LIMIT 1),
    (SELECT id FROM vibetype.event WHERE slug = 'benchmark-event-1')
  FROM vibetype.account a
  WHERE a.username = 'benchmark-user-1';

INSERT INTO vibetype_test.benchmark_personas (label, account_id, attendance_id, event_id) VALUES
  ('organizer_large', md5('benchmark-persona-organizer-large')::UUID, md5('benchmark-large-attendance-1-10')::UUID, md5('benchmark-large-event-1')::UUID),
  ('invitee_many',    md5('benchmark-persona-invitee-many')::UUID,    NULL,                                        md5('benchmark-invitation-event-1')::UUID),
  ('blocker_many',    md5('benchmark-persona-blocker-many')::UUID,    NULL,                                        (SELECT id FROM vibetype.event WHERE slug = 'benchmark-event-1'));

-- Query definitions: (name, sql, anonymous_only, authenticated_only, personas).
-- `personas` lists the skewed personas the query is also measured as (never for anonymous_only queries).
CREATE TABLE vibetype_test.benchmark_queries (
  name TEXT NOT NULL,
  query_sql TEXT NOT NULL,
  anonymous_only BOOLEAN NOT NULL DEFAULT FALSE,
  authenticated_only BOOLEAN NOT NULL DEFAULT FALSE,
  personas TEXT[] NOT NULL DEFAULT '{}'
);

GRANT SELECT ON vibetype_test.benchmark_queries TO vibetype_anonymous, vibetype_account;

INSERT INTO vibetype_test.benchmark_queries (name, query_sql, authenticated_only, personas) VALUES
  ('count_addresses', 'SELECT count(*) FROM vibetype.address', FALSE, '{invitee_many,blocker_many}'),
  ('count_attendances', 'SELECT count(*) FROM vibetype.attendance', FALSE, '{organizer_large,invitee_many}'),
  ('count_contacts', 'SELECT count(*) FROM vibetype.contact', FALSE, '{organizer_large,invitee_many}'),
  ('count_event_apps', 'SELECT count(*) FROM vibetype.event_app', FALSE, '{invitee_many,blocker_many}'),
  ('count_event_category_mappings', 'SELECT count(*) FROM vibetype.event_category_mapping', FALSE, '{invitee_many,blocker_many}'),
  ('count_event_format_mappings', 'SELECT count(*) FROM vibetype.event_format_mapping', FALSE, '{invitee_many,blocker_many}'),
  ('count_event_uploads', 'SELECT count(*) FROM vibetype.event_upload', FALSE, '{invitee_many,blocker_many}'),
  ('select_addresses_by_event', 'SELECT * FROM vibetype.address WHERE id = (SELECT address_id FROM vibetype.event WHERE id = ''{event_id}''::UUID)', FALSE, '{organizer_large,invitee_many}'),
  ('select_addresses_limit', 'SELECT * FROM vibetype.address LIMIT 20', FALSE, '{organizer_large,invitee_many,blocker_many}'),
  ('select_attendances_limit', 'SELECT * FROM vibetype.attendance LIMIT 20', FALSE, '{organizer_large,invitee_many,blocker_many}'),
  ('select_contacts_limit', 'SELECT * FROM vibetype.contact LIMIT 20', FALSE, '{organizer_large,invitee_many,blocker_many}'),
  ('select_event_apps_by_event', 'SELECT * FROM vibetype.event_app WHERE event_id = ''{event_id}''::UUID', FALSE, '{organizer_large,invitee_many}'),
  ('select_event_apps_limit', 'SELECT * FROM vibetype.event_app LIMIT 20', FALSE, '{organizer_large,invitee_many,blocker_many}'),
  ('select_event_category_mappings_by_event', 'SELECT * FROM vibetype.event_category_mapping WHERE event_id = ''{event_id}''::UUID', FALSE, '{organizer_large,invitee_many}'),
  ('select_event_category_mappings_limit', 'SELECT * FROM vibetype.event_category_mapping LIMIT 20', FALSE, '{organizer_large,invitee_many,blocker_many}'),
  ('select_event_format_mappings_by_event', 'SELECT * FROM vibetype.event_format_mapping WHERE event_id = ''{event_id}''::UUID', FALSE, '{organizer_large,invitee_many}'),
  ('select_event_format_mappings_limit', 'SELECT * FROM vibetype.event_format_mapping LIMIT 20', FALSE, '{organizer_large,invitee_many,blocker_many}'),
  ('select_event_uploads_by_event', 'SELECT * FROM vibetype.event_upload WHERE event_id = ''{event_id}''::UUID', FALSE, '{organizer_large,invitee_many}'),
  ('select_event_uploads_limit', 'SELECT * FROM vibetype.event_upload LIMIT 20', FALSE, '{organizer_large,invitee_many,blocker_many}'),
  ('account_block_ids',          'SELECT vibetype_test.account_block_ids()',                                                FALSE, '{blocker_many}'),
  ('account_search',             'SELECT * FROM vibetype.account_search(''benchmark'')',                                    TRUE,  '{blocker_many}'),
  ('attendance_claim_array',     'SELECT vibetype.attendance_claim_array()',                                                FALSE, '{}'),
  ('event_guest_count_maximum',  'SELECT vibetype.event_guest_count_maximum(''{event_id}''::UUID)',                         FALSE, '{organizer_large,invitee_many,blocker_many}'),
  ('event_search',               'SELECT * FROM vibetype.event_search(''benchmark'')',                                      TRUE,  '{invitee_many,blocker_many}'),
  ('events_invited',             'SELECT vibetype_test.events_invited()',                                                   FALSE, '{invitee_many}'),
  ('guest_claim_array',          'SELECT vibetype.guest_claim_array()',                                                     FALSE, '{}'),
  ('guest_contact_ids',          'SELECT * FROM vibetype.guest_contact_ids()',                                              FALSE, '{organizer_large,invitee_many}'),
  ('guest_count',                'SELECT vibetype.guest_count(''{event_id}''::UUID)',                                       FALSE, '{organizer_large}'),
  ('select_accounts',            'SELECT * FROM vibetype.account',                                                          FALSE, '{blocker_many}'),
  ('select_attendance',          'SELECT * FROM vibetype.attendance',                                                       FALSE, '{organizer_large,invitee_many}'),
  ('select_contacts',            'SELECT * FROM vibetype.contact',                                                          FALSE, '{invitee_many,blocker_many}'),
  ('select_contacts_by_creator', 'SELECT * FROM vibetype.contact WHERE created_by = ''{account_id}''::UUID',                FALSE, '{organizer_large}'),
  ('select_events',              'SELECT * FROM vibetype.event',                                                            FALSE, '{invitee_many,blocker_many}'),
  ('select_guests',              'SELECT * FROM vibetype.guest',                                                            FALSE, '{organizer_large,invitee_many,blocker_many}'),
  ('select_guests_by_event',     'SELECT * FROM vibetype.guest WHERE event_id = ''{event_id}''::UUID',                      FALSE, '{organizer_large}'),
  -- Rewrites the row unchanged, so repeated runs keep the data stable; sorted last so its dead tuples don't affect earlier queries.
  ('update_attendance',          'UPDATE vibetype.attendance SET checked_out = checked_out WHERE id = ''{attendance_id}''::UUID', TRUE, '{organizer_large}');

-- Collect all results into a single array.
CREATE TABLE vibetype_test.benchmark_results (result JSONB);

GRANT INSERT ON vibetype_test.benchmark_results TO vibetype_anonymous, vibetype_account;

-- Anonymous benchmarks.
SET ROLE vibetype_anonymous;
SELECT set_config('jwt.claims.sub', '', false);

INSERT INTO vibetype_test.benchmark_results
  SELECT vibetype_test.benchmark_measure(q.name, 'vibetype_anonymous', replace(replace(replace(q.query_sql, '{account_id}', p.account_id::TEXT), '{attendance_id}', coalesce(p.attendance_id::TEXT, '')), '{event_id}', p.event_id::TEXT))
  FROM vibetype_test.benchmark_queries q, vibetype_test.benchmark_personas p
  WHERE p.label = '' AND NOT q.authenticated_only
  ORDER BY q.name;

RESET ROLE;

-- Authenticated benchmarks: the default persona, then each skewed persona on its subset of queries.
-- \gexec runs the generated statements in order, so each persona's jwt.claims.sub is set before its measurements.
SET ROLE vibetype_account;

SELECT s.statement
FROM (
  SELECT
    p.label,
    1 AS step,
    format('SELECT set_config(''jwt.claims.sub'', %L, false)', p.account_id) AS statement
  FROM vibetype_test.benchmark_personas p
  UNION ALL
  SELECT
    p.label,
    2,
    format(
      'INSERT INTO vibetype_test.benchmark_results SELECT vibetype_test.benchmark_measure(%L, ''vibetype_account'', %L)',
      q.name || CASE WHEN p.label = '' THEN '' ELSE '@' || p.label END,
      replace(replace(replace(q.query_sql, '{account_id}', p.account_id::TEXT), '{attendance_id}', coalesce(p.attendance_id::TEXT, '')), '{event_id}', p.event_id::TEXT)
    )
  FROM vibetype_test.benchmark_personas p
  JOIN vibetype_test.benchmark_queries q
    ON (p.label = '' AND NOT q.anonymous_only)
    OR (p.label = ANY(q.personas) AND NOT q.anonymous_only)
) s
ORDER BY s.label, s.step, s.statement
\gexec

RESET ROLE;

-- Restore stdout for final output.
\o

-- Output all results as a single JSON array.
SELECT jsonb_agg(result ORDER BY result->>'name', result->>'role')
  FROM vibetype_test.benchmark_results;
