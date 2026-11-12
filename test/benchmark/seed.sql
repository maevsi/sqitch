-- Deterministic synthetic data for benchmark measurements.
-- Generates 1000 accounts, 100 events, 1000 contacts, ~1000 guests, and 200 attendances.
-- Uses bulk inserts for speed; only a few accounts go through proper registration.

DO $$
DECLARE
  _legal_term_id UUID;
  _account_id UUID;
  _password_hash TEXT;
  _i INT;
BEGIN
  -- Legal term (required for account registration)
  INSERT INTO vibetype.legal_term (term, version)
    VALUES ('Benchmark terms of service', '0.0.0')
    RETURNING id INTO _legal_term_id;

  -- Use a fixed, precomputed bcrypt hash of 'benchmark-password' to keep seed data deterministic.
  _password_hash := '$2b$10$abcdefghijklmnopqrstuvABCDEFGHijkLMNOPQRstu';

  -- Register 5 accounts properly (for benchmark subjects with full verification)
  FOR _i IN 1..5 LOOP
    PERFORM vibetype.account_registration(
      '1970-01-01'::DATE,
      'benchmark-' || _i || '@example.test',
      CASE WHEN _i % 2 = 0 THEN 'en' ELSE 'de' END,
      _legal_term_id,
      'benchmark-password',
      'benchmark-user-' || _i
    );

    SELECT id INTO _account_id
      FROM vibetype.account
      WHERE username = 'benchmark-user-' || _i;

    PERFORM vibetype.account_email_address_verification(
      (SELECT email_address_verification FROM vibetype_private.account WHERE id = _account_id)
    );
  END LOOP;

  -- Bulk insert 995 more accounts directly (bypassing slow bcrypt per-row)
  INSERT INTO vibetype_private.account (id, birth_date, email_address, password_hash, last_activity)
    SELECT
      md5('benchmark-account-' || i)::UUID,
      '1990-01-01'::DATE,
      'benchmark-' || i || '@example.test',
      _password_hash,
      '1970-01-01 00:00:00'::timestamp
    FROM generate_series(6, 1000) AS i;

  INSERT INTO vibetype.account (id, username)
    SELECT
      md5('benchmark-account-' || i)::UUID,
      'benchmark-user-' || i
    FROM generate_series(6, 1000) AS i;

  -- Self-contacts for bulk accounts
  INSERT INTO vibetype.contact (account_id, created_by)
    SELECT
      md5('benchmark-account-' || i)::UUID,
      md5('benchmark-account-' || i)::UUID
    FROM generate_series(6, 1000) AS i;

  -- Legal term acceptance for bulk accounts
  INSERT INTO vibetype.legal_term_acceptance (account_id, legal_term_id)
    SELECT md5('benchmark-account-' || i)::UUID, _legal_term_id
    FROM generate_series(6, 1000) AS i;

  RAISE NOTICE 'Seeded 1000 accounts';
END $$;

-- Collect all account IDs into a temp table for efficient referencing
CREATE TEMP TABLE _benchmark_accounts AS
  SELECT id, username, row_number() OVER (ORDER BY username) AS seq
  FROM vibetype.account
  WHERE username LIKE 'benchmark-user-%';

-- 100 events: first 20 accounts each organize 5 events
INSERT INTO vibetype.event (name, slug, visibility, start, "end", guest_count_maximum, created_by, description, language)
  SELECT
    'Benchmark Event ' || event_num,
    'benchmark-event-' || event_num,
    (ARRAY['public', 'public', 'public', 'private', 'unlisted'])[1 + (event_num % 5)]::vibetype.event_visibility,
    '2025-06-01'::TIMESTAMPTZ + (event_num || ' hours')::INTERVAL,
    '2025-06-01'::TIMESTAMPTZ + (event_num || ' hours')::INTERVAL + '4 hours'::INTERVAL,
    CASE WHEN event_num % 10 = 0 THEN 50 ELSE NULL END,
    a.id,
    'Description for benchmark event ' || event_num || '. Performance test under row-level security.',
    CASE WHEN event_num % 2 = 0 THEN 'en' ELSE 'de' END::vibetype.language
  FROM (
    SELECT
      ((organizer_seq - 1) * 5 + event_offset) AS event_num,
      organizer_seq
    FROM generate_series(1, 20) AS organizer_seq,
         generate_series(1, 5) AS event_offset
  ) sub
  JOIN _benchmark_accounts a ON a.seq = sub.organizer_seq;

DO $$ BEGIN RAISE NOTICE 'Seeded 100 events'; END $$;

-- Collect event data for guest assignment
CREATE TEMP TABLE _benchmark_events AS
  SELECT id, slug, created_by, row_number() OVER (ORDER BY slug) AS seq
  FROM vibetype.event
  WHERE slug LIKE 'benchmark-event-%';

-- 1000 contacts: first 20 accounts each create 50 contacts
INSERT INTO vibetype.contact (email_address, first_name, last_name, created_by)
  SELECT
    'contact-' || contact_num || '@example.test',
    'First' || contact_num,
    'Last' || contact_num,
    a.id
  FROM (
    SELECT
      ((owner_seq - 1) * 50 + contact_offset) AS contact_num,
      owner_seq
    FROM generate_series(1, 20) AS owner_seq,
         generate_series(1, 50) AS contact_offset
  ) sub
  JOIN _benchmark_accounts a ON a.seq = sub.owner_seq;

DO $$ BEGIN RAISE NOTICE 'Seeded 1000 contacts'; END $$;

-- ~1000 guests: 10 per event, using contacts owned by the event organizer
-- Each organizer has 50 contacts; with 5 events × 10 guests = 50, so each contact is used once.
INSERT INTO vibetype.guest (contact_id, event_id)
  SELECT c.id, e.id
  FROM _benchmark_events e
  JOIN LATERAL (
    SELECT ct.id, row_number() OVER (ORDER BY ct.id) AS rn
    FROM vibetype.contact ct
    WHERE ct.created_by = e.created_by
      AND ct.account_id IS NULL  -- exclude self-contacts
  ) c ON c.rn <= 10;

DO $$ BEGIN RAISE NOTICE 'Seeded guests'; END $$;

-- 200 attendances: first 2 guests per event for all 100 events
INSERT INTO vibetype.attendance (guest_id)
  SELECT g.id
  FROM (
    SELECT id, event_id, row_number() OVER (PARTITION BY event_id ORDER BY id) AS rn
    FROM vibetype.guest
    WHERE event_id IN (SELECT id FROM _benchmark_events)
  ) g
  WHERE g.rn <= 2;

DO $$ BEGIN RAISE NOTICE 'Seeded attendances'; END $$;

-- 50 account blocks: accounts 1-50 each block account 51
DO $$
DECLARE
  _blocker_id UUID;
  _blocked_id UUID;
  _i INT;
BEGIN
  SELECT id INTO _blocked_id FROM _benchmark_accounts WHERE seq = 51;

  FOR _i IN 1..50 LOOP
    SELECT id INTO _blocker_id FROM _benchmark_accounts WHERE seq = _i;

    PERFORM set_config('jwt.claims.sub', _blocker_id::TEXT, true);

    INSERT INTO vibetype.account_block (blocked_account_id, created_by)
      VALUES (_blocked_id, _blocker_id);
  END LOOP;

  PERFORM set_config('jwt.claims.sub', '', true);
END $$;

DO $$ BEGIN RAISE NOTICE 'Seeded account blocks'; END $$;

-- Summary
DO $$
DECLARE
  _accounts INT;
  _events INT;
  _contacts INT;
  _guests INT;
  _attendances INT;
BEGIN
  SELECT count(*) INTO _accounts FROM vibetype.account WHERE username LIKE 'benchmark-%';
  SELECT count(*) INTO _events FROM vibetype.event WHERE slug LIKE 'benchmark-%';
  SELECT count(*) INTO _contacts FROM vibetype.contact WHERE email_address LIKE 'contact-%';
  SELECT count(*) INTO _guests FROM vibetype.guest;
  SELECT count(*) INTO _attendances FROM vibetype.attendance;
  RAISE NOTICE 'Benchmark seed complete: % accounts, % events, % contacts, % guests, % attendances',
    _accounts, _events, _contacts, _guests, _attendances;
END $$;

-- Cleanup temp tables
DROP TABLE _benchmark_accounts;
DROP TABLE _benchmark_events;

-- ---------------------------------------------------------------------------
-- Skewed personas
--
-- The data above is spread evenly, so every query is fast whatever its plan.
-- The accounts below are outliers that make scaling problems visible:
--   benchmark-organizer-large: 500 events with 40000 guests and 4000 attendances
--   benchmark-invitee-many:    invited to 3000 events of 300 different organizers
--   benchmark-blocker-many:    blocks 3000 accounts
-- All rows are bulk inserted with deterministic md5-based ids.
-- ---------------------------------------------------------------------------

DO $$
DECLARE
  _password_hash CONSTANT TEXT := '$2b$10$abcdefghijklmnopqrstuvABCDEFGHijkLMNOPQRstu';
BEGIN
  -- Accounts: 3 personas, 300 organizers that invite benchmark-invitee-many, 3000 accounts blocked by benchmark-blocker-many.
  CREATE TEMP TABLE _benchmark_skewed_accounts AS
    SELECT md5('benchmark-persona-' || p)::UUID AS id, 'benchmark-' || p AS username
      FROM unnest(ARRAY['organizer-large', 'invitee-many', 'blocker-many']) AS p
    UNION ALL
    SELECT md5('benchmark-invitation-organizer-' || i)::UUID, 'benchmark-invitation-organizer-' || i
      FROM generate_series(1, 300) AS i
    UNION ALL
    SELECT md5('benchmark-blocked-account-' || i)::UUID, 'benchmark-blocked-account-' || i
      FROM generate_series(1, 3000) AS i;

  INSERT INTO vibetype_private.account (id, birth_date, email_address, password_hash, last_activity)
    SELECT id, '1990-01-01'::DATE, username || '@example.test', _password_hash, '1970-01-01 00:00:00'::timestamp
    FROM _benchmark_skewed_accounts;

  INSERT INTO vibetype.account (id, username)
    SELECT id, username FROM _benchmark_skewed_accounts;

  DROP TABLE _benchmark_skewed_accounts;

  -- benchmark-organizer-large: 500 events (every 5th has a guest limit, every 10th is nearly full).
  INSERT INTO vibetype.event (id, name, slug, visibility, start, "end", guest_count_maximum, created_by, description, language)
    SELECT
      md5('benchmark-large-event-' || e)::UUID,
      'Benchmark Large Event ' || e,
      'benchmark-large-event-' || e,
      (ARRAY['public', 'public', 'public', 'private', 'unlisted'])[1 + (e % 5)]::vibetype.event_visibility,
      '2025-07-01'::TIMESTAMPTZ + (e || ' hours')::INTERVAL,
      '2025-07-01'::TIMESTAMPTZ + (e || ' hours')::INTERVAL + '4 hours'::INTERVAL,
      CASE WHEN e % 10 = 0 THEN 80 WHEN e % 5 = 0 THEN 1000 ELSE NULL END,
      md5('benchmark-persona-organizer-large')::UUID,
      'Description for large benchmark event ' || e || '. Performance test under row-level security.',
      'en'::vibetype.language
    FROM generate_series(1, 500) AS e;

  -- 2000 contacts owned by the organizer; each event invites 80 of them, which makes 40000 guests.
  INSERT INTO vibetype.contact (id, email_address, first_name, last_name, created_by)
    SELECT
      md5('benchmark-large-contact-' || c)::UUID,
      'large-contact-' || c || '@example.test',
      'LargeFirst' || c,
      'LargeLast' || c,
      md5('benchmark-persona-organizer-large')::UUID
    FROM generate_series(1, 2000) AS c;

  INSERT INTO vibetype.guest (id, contact_id, event_id)
    SELECT
      md5('benchmark-large-guest-' || e || '-' || k)::UUID,
      md5('benchmark-large-contact-' || (((e - 1) * 80 + k - 1) % 2000 + 1))::UUID,
      md5('benchmark-large-event-' || e)::UUID
    FROM generate_series(1, 500) AS e, generate_series(1, 80) AS k;

  -- 10% of the guests attended.
  INSERT INTO vibetype.attendance (id, guest_id)
    SELECT
      md5('benchmark-large-attendance-' || e || '-' || k)::UUID,
      md5('benchmark-large-guest-' || e || '-' || k)::UUID
    FROM generate_series(1, 500) AS e, generate_series(10, 80, 10) AS k;

  -- benchmark-invitee-many: every organizer has one contact for the invitee (unique per created_by and account_id).
  INSERT INTO vibetype.contact (id, account_id, created_by)
    SELECT
      md5('benchmark-invitation-contact-' || o)::UUID,
      md5('benchmark-persona-invitee-many')::UUID,
      md5('benchmark-invitation-organizer-' || o)::UUID
    FROM generate_series(1, 300) AS o;

  INSERT INTO vibetype.event (id, name, slug, visibility, start, "end", guest_count_maximum, created_by, description, language)
    SELECT
      md5('benchmark-invitation-event-' || n)::UUID,
      'Benchmark Invitation Event ' || n,
      'benchmark-invitation-event-' || n,
      (ARRAY['public', 'private', 'unlisted'])[1 + (n % 3)]::vibetype.event_visibility,
      '2025-08-01'::TIMESTAMPTZ + (n || ' hours')::INTERVAL,
      '2025-08-01'::TIMESTAMPTZ + (n || ' hours')::INTERVAL + '4 hours'::INTERVAL,
      CASE WHEN n % 10 = 0 THEN 50 ELSE NULL END,
      md5('benchmark-invitation-organizer-' || ((n - 1) % 300 + 1))::UUID,
      'Description for invitation benchmark event ' || n || '. Performance test under row-level security.',
      'en'::vibetype.language
    FROM generate_series(1, 3000) AS n;

  INSERT INTO vibetype.guest (id, contact_id, event_id)
    SELECT
      md5('benchmark-invitation-guest-' || n)::UUID,
      md5('benchmark-invitation-contact-' || ((n - 1) % 300 + 1))::UUID,
      md5('benchmark-invitation-event-' || n)::UUID
    FROM generate_series(1, 3000) AS n;

  -- benchmark-blocker-many: 3000 blocks.
  PERFORM set_config('jwt.claims.sub', md5('benchmark-persona-blocker-many'), true);

  INSERT INTO vibetype.account_block (id, blocked_account_id, created_by)
    SELECT
      md5('benchmark-block-' || i)::UUID,
      md5('benchmark-blocked-account-' || i)::UUID,
      md5('benchmark-persona-blocker-many')::UUID
    FROM generate_series(1, 3000) AS i;

  PERFORM set_config('jwt.claims.sub', '', true);

  RAISE NOTICE 'Seeded skewed personas';
END $$;
