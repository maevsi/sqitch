\echo test_event/unlisted_link...

BEGIN;

SAVEPOINT unlisted_link_event_select;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  eventA UUID;
  eventP UUID;
  invoker UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Unlisted by A', 'unlisted-by-a', '2025-06-01 20:00', 'unlisted');
  eventP := vibetype_test.event_create(accountA, 'Public by A', 'public-by-a', '2025-06-01 20:00', 'public');

  -- null stands for the anonymous invoker
  FOREACH invoker IN ARRAY ARRAY[NULL, accountB]::UUID[] LOOP
    PERFORM vibetype_test.event_test('unlisted event without settings', invoker, ARRAY[eventP]::UUID[]);

    PERFORM set_config('event_link.username', 'a', true);
    PERFORM set_config('event_link.slug', 'unlisted-by-a', true);
    PERFORM vibetype_test.event_test('unlisted event with matching settings', invoker, ARRAY[eventA, eventP]::UUID[]);

    PERFORM set_config('event_link.slug', 'unlisted-by-x', true);
    PERFORM vibetype_test.event_test('unlisted event with wrong slug', invoker, ARRAY[eventP]::UUID[]);

    PERFORM set_config('event_link.username', 'x', true);
    PERFORM set_config('event_link.slug', 'unlisted-by-a', true);
    PERFORM vibetype_test.event_test('unlisted event with wrong username', invoker, ARRAY[eventP]::UUID[]);

    PERFORM set_config('event_link.username', 'b', true);
    PERFORM vibetype_test.event_test('unlisted event with the username of another account', invoker, ARRAY[eventP]::UUID[]);

    PERFORM set_config('event_link.username', '', true);
    PERFORM set_config('event_link.slug', '', true);
    PERFORM vibetype_test.event_test('unlisted event with reset settings', invoker, ARRAY[eventP]::UUID[]);
  END LOOP;
END $$;
ROLLBACK TO SAVEPOINT unlisted_link_event_select;

SAVEPOINT unlisted_link_event_select_sibling;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  eventA UUID;
  eventB UUID;
  eventP UUID;
  invoker UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Unlisted A by A', 'unlisted-a', '2025-06-01 20:00', 'unlisted');
  eventB := vibetype_test.event_create(accountA, 'Unlisted B by A', 'unlisted-b', '2025-06-01 20:00', 'unlisted');
  eventP := vibetype_test.event_create(accountA, 'Public by A', 'public-by-a', '2025-06-01 20:00', 'public');

  PERFORM set_config('event_link.username', 'a', true);
  PERFORM set_config('event_link.slug', 'unlisted-a', true);

  FOREACH invoker IN ARRAY ARRAY[NULL, accountB]::UUID[] LOOP
    PERFORM vibetype_test.event_test('only the linked unlisted event is visible next to public events', invoker, ARRAY[eventA, eventP]::UUID[]);
  END LOOP;

  PERFORM vibetype_test.event_test('the organizer sees both unlisted events', accountA, ARRAY[eventA, eventB, eventP]::UUID[]);
END $$;
ROLLBACK TO SAVEPOINT unlisted_link_event_select_sibling;

SAVEPOINT unlisted_link_event_select_private;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  eventP UUID;
  eventPrivate UUID;
  invoker UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  eventPrivate := vibetype_test.event_create(accountA, 'Private by A', 'private-by-a', '2025-06-01 20:00', 'private');
  eventP := vibetype_test.event_create(accountA, 'Public by A', 'public-by-a', '2025-06-01 20:00', 'public');

  PERFORM set_config('event_link.username', 'a', true);
  PERFORM set_config('event_link.slug', 'private-by-a', true);

  FOREACH invoker IN ARRAY ARRAY[NULL, accountB]::UUID[] LOOP
    PERFORM vibetype_test.event_test('a private event stays invisible when named by the settings', invoker, ARRAY[eventP]::UUID[]);
  END LOOP;
END $$;
ROLLBACK TO SAVEPOINT unlisted_link_event_select_private;

SAVEPOINT unlisted_link_event_select_block;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  eventA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Unlisted by A', 'unlisted-by-a', '2025-06-01 20:00', 'unlisted');

  PERFORM set_config('event_link.username', 'a', true);
  PERFORM set_config('event_link.slug', 'unlisted-by-a', true);

  PERFORM vibetype_test.event_test('unlisted event with settings before the block', accountB, ARRAY[eventA]::UUID[]);

  PERFORM vibetype_test.account_block_create(accountA, accountB);
  PERFORM vibetype_test.event_test('unlisted event of a blocking organizer', accountB, ARRAY[]::UUID[]);

  PERFORM vibetype_test.account_block_delete(accountA, accountB);
  PERFORM vibetype_test.account_block_create(accountB, accountA);
  PERFORM vibetype_test.event_test('unlisted event of a blocked organizer', accountB, ARRAY[]::UUID[]);
END $$;
ROLLBACK TO SAVEPOINT unlisted_link_event_select_block;

SAVEPOINT unlisted_link_event_select_maximum;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  eventA UUID;
  invoker UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');
  eventA := vibetype_test.event_create(accountA, 'Unlisted by A', 'unlisted-by-a', '2025-06-01 20:00', 'unlisted');

  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.event SET guest_count_maximum = 1 WHERE id = eventA;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM set_config('event_link.username', 'a', true);
  PERFORM set_config('event_link.slug', 'unlisted-by-a', true);

  FOREACH invoker IN ARRAY ARRAY[NULL, accountB]::UUID[] LOOP
    PERFORM vibetype_test.event_test('unlisted event below the guest maximum', invoker, ARRAY[eventA]::UUID[]);
  END LOOP;

  PERFORM vibetype_test.guest_create(accountC, eventA, vibetype_test.contact_select_by_account_id(accountC));

  FOREACH invoker IN ARRAY ARRAY[NULL, accountB]::UUID[] LOOP
    PERFORM vibetype_test.event_test('unlisted event at the guest maximum', invoker, ARRAY[]::UUID[]);
  END LOOP;
END $$;
ROLLBACK TO SAVEPOINT unlisted_link_event_select_maximum;

SAVEPOINT unlisted_link_guest_join;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactBB UUID;
  eventA UUID;
  eventPrivate UUID;
  guestBA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');
  contactBB := vibetype_test.contact_select_by_account_id(accountB);
  eventA := vibetype_test.event_create(accountA, 'Unlisted by A', 'unlisted-by-a', '2025-06-01 20:00', 'unlisted');
  eventPrivate := vibetype_test.event_create(accountA, 'Private by A', 'private-by-a', '2025-06-01 20:00', 'private');

  PERFORM vibetype_test.guest_join_rejected_test('an unlisted event cannot be joined without settings', accountB, eventA, contactBB, '42501');

  PERFORM set_config('event_link.username', 'a', true);
  PERFORM set_config('event_link.slug', 'private-by-a', true);
  PERFORM vibetype_test.guest_join_rejected_test('a private event cannot be joined with settings', accountB, eventPrivate, contactBB, '42501');

  PERFORM set_config('event_link.slug', 'unlisted-by-a', true);
  PERFORM vibetype_test.guest_join_rejected_test('an unlisted event cannot be joined for someone else', accountC, eventA, contactBB, '42501');

  PERFORM vibetype_test.invoker_set(accountB);
  INSERT INTO vibetype.guest(contact_id, event_id, feedback)
  VALUES (contactBB, eventA, 'accepted')
  RETURNING id INTO guestBA;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.guest_test('the joined guest is visible to its account', accountB, ARRAY[guestBA]);
  PERFORM vibetype_test.guest_test('the joined guest is visible to the organizer', accountA, ARRAY[guestBA]);

  PERFORM set_config('event_link.username', '', true);
  PERFORM set_config('event_link.slug', '', true);
  PERFORM vibetype_test.guest_join_rejected_test('an unlisted event cannot be joined again without settings', accountC, eventA, vibetype_test.contact_select_by_account_id(accountC), '42501');
END $$;
ROLLBACK TO SAVEPOINT unlisted_link_guest_join;

SAVEPOINT unlisted_link_event_guest_count_maximum;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  eventA UUID;
  eventPrivate UUID;
  invoker UUID;
  maxCount INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.invoker_set(accountA);
  INSERT INTO vibetype.event (created_by, name, slug, start, visibility, guest_count_maximum)
  VALUES (accountA, 'Unlisted by A', 'unlisted-by-a', '2025-06-01 20:00', 'unlisted', 40)
  RETURNING id INTO eventA;
  INSERT INTO vibetype.event (created_by, name, slug, start, visibility, guest_count_maximum)
  VALUES (accountA, 'Private by A', 'private-by-a', '2025-06-01 20:00', 'private', 30)
  RETURNING id INTO eventPrivate;
  PERFORM vibetype_test.invoker_set_previous();

  FOREACH invoker IN ARRAY ARRAY[NULL, accountB]::UUID[] LOOP
    IF invoker IS NULL THEN
      PERFORM vibetype_test.invoker_set_anonymous();
    ELSE
      PERFORM vibetype_test.invoker_set(invoker);
    END IF;

    PERFORM set_config('event_link.username', '', true);
    PERFORM set_config('event_link.slug', '', true);
    IF vibetype.event_guest_count_maximum(eventA) IS NOT NULL THEN
      RAISE EXCEPTION 'Test failed: expected NULL for an unlisted event without settings';
    END IF;

    PERFORM set_config('event_link.username', 'a', true);
    PERFORM set_config('event_link.slug', 'unlisted-by-a', true);
    maxCount := vibetype.event_guest_count_maximum(eventA);
    IF maxCount IS DISTINCT FROM 40 THEN
      RAISE EXCEPTION 'Test failed: expected 40 for the linked unlisted event, got %', maxCount;
    END IF;

    PERFORM set_config('event_link.slug', 'private-by-a', true);
    IF vibetype.event_guest_count_maximum(eventPrivate) IS NOT NULL THEN
      RAISE EXCEPTION 'Test failed: expected NULL for a private event named by the settings';
    END IF;

    PERFORM vibetype_test.invoker_set_previous();
  END LOOP;
END $$;
ROLLBACK TO SAVEPOINT unlisted_link_event_guest_count_maximum;

SAVEPOINT unlisted_link_address;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  eventA UUID;
  invoker UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Unlisted by A', 'unlisted-by-a', '2025-06-01 20:00', 'unlisted');
  PERFORM vibetype_test.event_update_address_coordinates(eventA, 50.0, 8.0);

  FOREACH invoker IN ARRAY ARRAY[NULL, accountB]::UUID[] LOOP
    IF invoker IS NULL THEN
      PERFORM vibetype_test.invoker_set_anonymous();
    ELSE
      PERFORM vibetype_test.invoker_set(invoker);
    END IF;

    PERFORM set_config('event_link.username', '', true);
    PERFORM set_config('event_link.slug', '', true);
    IF EXISTS (SELECT 1 FROM vibetype.address) THEN
      RAISE EXCEPTION 'Test failed: the address of an unlisted event is visible without settings';
    END IF;

    PERFORM set_config('event_link.username', 'a', true);
    PERFORM set_config('event_link.slug', 'unlisted-by-a', true);
    IF NOT EXISTS (SELECT 1 FROM vibetype.address) THEN
      RAISE EXCEPTION 'Test failed: the address of the linked unlisted event is not visible';
    END IF;

    PERFORM vibetype_test.invoker_set_previous();
  END LOOP;
END $$;
ROLLBACK TO SAVEPOINT unlisted_link_address;

ROLLBACK;
