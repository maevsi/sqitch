-- Deterministic synthetic data for benchmark measurements.
-- Generates 100 accounts, 50 events, 200 contacts, 500 guests, and 100 attendances.
-- Uses setseed() for reproducible random values across CI runs.

SELECT setseed(0.42);

DO $$
DECLARE
  _legal_term_id UUID;
  _account_ids UUID[] := ARRAY[]::UUID[];
  _event_ids UUID[] := ARRAY[]::UUID[];
  _contact_ids UUID[] := ARRAY[]::UUID[];
  _guest_ids UUID[] := ARRAY[]::UUID[];
  _account_id UUID;
  _event_id UUID;
  _contact_id UUID;
  _guest_id UUID;
  _i INT;
  _organizer_id UUID;
  _visibility TEXT;
  _visibilities TEXT[] := ARRAY['public', 'public', 'public', 'private', 'unlisted'];
BEGIN
  -- Legal term (required for account registration)
  INSERT INTO vibetype.legal_term (term, version)
    VALUES ('Benchmark terms of service', '0.0.0')
    RETURNING id INTO _legal_term_id;

  -- 100 accounts
  FOR _i IN 1..100 LOOP
    PERFORM vibetype.account_registration(
      '1990-01-01'::DATE,
      'benchmark-' || _i || '@example.test',
      CASE WHEN _i % 2 = 0 THEN 'en' ELSE 'de' END,
      _legal_term_id,
      'password-' || _i,
      'benchmark-user-' || _i
    );

    SELECT id INTO _account_id
      FROM vibetype.account
      WHERE username = 'benchmark-user-' || _i;

    -- Verify email so JWT creation works
    PERFORM vibetype.account_email_address_verification(
      (
        SELECT email_address_verification
        FROM vibetype_private.account
        WHERE id = _account_id
      )
    );

    _account_ids := array_append(_account_ids, _account_id);
  END LOOP;

  -- 50 events spread across organizers
  FOR _i IN 1..50 LOOP
    _organizer_id := _account_ids[1 + (_i % 20)];
    _visibility := _visibilities[1 + (_i % array_length(_visibilities, 1))];

    PERFORM set_config('jwt.claims.sub', _organizer_id::TEXT, true);
    SET LOCAL ROLE = 'vibetype_account';

    INSERT INTO vibetype.event (
      name, slug, visibility, start, "end",
      guest_count_maximum, created_by, description, language
    ) VALUES (
      'Benchmark Event ' || _i,
      'benchmark-event-' || _i,
      _visibility::vibetype.event_visibility,
      '2025-06-01'::TIMESTAMPTZ + (_i || ' days')::INTERVAL,
      '2025-06-01'::TIMESTAMPTZ + (_i || ' days')::INTERVAL + '4 hours'::INTERVAL,
      CASE WHEN _i % 5 = 0 THEN 20 ELSE NULL END,
      _organizer_id,
      'Description for benchmark event number ' || _i || '. This event tests database query performance under row-level security policies.',
      CASE WHEN _i % 2 = 0 THEN 'en' ELSE 'de' END
    ) RETURNING id INTO _event_id;

    _event_ids := array_append(_event_ids, _event_id);

    RESET ROLE;
    PERFORM set_config('jwt.claims.sub', '', true);
  END LOOP;

  -- 200 extra contacts (each of the first 40 accounts creates 5 contacts)
  FOR _i IN 1..200 LOOP
    _account_id := _account_ids[1 + ((_i - 1) % 40)];

    PERFORM set_config('jwt.claims.sub', _account_id::TEXT, true);
    SET LOCAL ROLE = 'vibetype_account';

    INSERT INTO vibetype.contact (
      email_address, first_name, last_name, created_by
    ) VALUES (
      'contact-' || _i || '@example.test',
      'First' || _i,
      'Last' || _i,
      _account_id
    ) RETURNING id INTO _contact_id;

    _contact_ids := array_append(_contact_ids, _contact_id);

    RESET ROLE;
    PERFORM set_config('jwt.claims.sub', '', true);
  END LOOP;

  -- 500 guests: distribute across events using contacts from the organizer
  FOR _i IN 1..500 LOOP
    _event_id := _event_ids[1 + ((_i - 1) % 50)];

    SELECT created_by INTO _organizer_id
      FROM vibetype.event WHERE id = _event_id;

    -- Pick a contact owned by the organizer
    SELECT id INTO _contact_id
      FROM vibetype.contact
      WHERE created_by = _organizer_id
        AND id NOT IN (SELECT contact_id FROM vibetype.guest WHERE event_id = _event_id)
      LIMIT 1;

    -- Skip if organizer has no unused contacts for this event
    CONTINUE WHEN _contact_id IS NULL;

    PERFORM set_config('jwt.claims.sub', _organizer_id::TEXT, true);
    SET LOCAL ROLE = 'vibetype_account';

    INSERT INTO vibetype.guest (contact_id, event_id)
      VALUES (_contact_id, _event_id)
      RETURNING id INTO _guest_id;

    _guest_ids := array_append(_guest_ids, _guest_id);

    RESET ROLE;
    PERFORM set_config('jwt.claims.sub', '', true);
  END LOOP;

  -- 100 attendances on first 100 guests (where the organizer creates the attendance)
  FOR _i IN 1..LEAST(100, array_length(_guest_ids, 1)) LOOP
    _guest_id := _guest_ids[_i];

    SELECT e.created_by INTO _organizer_id
      FROM vibetype.guest g
      JOIN vibetype.event e ON e.id = g.event_id
      WHERE g.id = _guest_id;

    PERFORM set_config('jwt.claims.sub', _organizer_id::TEXT, true);
    SET LOCAL ROLE = 'vibetype_account';

    INSERT INTO vibetype.attendance (guest_id)
      VALUES (_guest_id);

    RESET ROLE;
    PERFORM set_config('jwt.claims.sub', '', true);
  END LOOP;

  -- 5 account blocks (accounts 1-5 each block account 6)
  FOR _i IN 1..5 LOOP
    PERFORM set_config('jwt.claims.sub', _account_ids[_i]::TEXT, true);
    SET LOCAL ROLE = 'vibetype_account';

    INSERT INTO vibetype.account_block (blocked_account_id, created_by)
      VALUES (_account_ids[6], _account_ids[_i]);

    RESET ROLE;
    PERFORM set_config('jwt.claims.sub', '', true);
  END LOOP;

  RAISE NOTICE 'Benchmark seed complete: % accounts, % events, % contacts, % guests, % attendances',
    array_length(_account_ids, 1),
    array_length(_event_ids, 1),
    array_length(_contact_ids, 1),
    array_length(_guest_ids, 1),
    LEAST(100, array_length(_guest_ids, 1));
END $$;
