\echo test_event_outbox...

BEGIN;

-- Test that creating an event publishes an outbox event with op 'c'
SAVEPOINT event_outbox_insert;
DO $$
DECLARE
  accountA UUID;
  eventA UUID;
  outbox_count INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  eventA := vibetype_test.event_create(accountA, 'Test Event', 'test-event', '2025-06-01 20:00', 'public');

  SELECT count(*) INTO outbox_count
    FROM vibetype_private.outbox
    WHERE aggregate_type = 'event'
      AND aggregate_id = eventA
      AND type = 'event'
      AND payload = jsonb_build_object('id', eventA, 'type', 'event', 'op', 'c');

  IF outbox_count != 1 THEN
    RAISE EXCEPTION 'Test failed (event_outbox_insert): expected 1 outbox event, got %', outbox_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_outbox_insert;

-- Test that updating an event publishes an outbox event with op 'u'
SAVEPOINT event_outbox_update;
DO $$
DECLARE
  accountA UUID;
  eventA UUID;
  outbox_count INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  eventA := vibetype_test.event_create(accountA, 'Test Event', 'test-event', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.event SET name = 'Updated Event' WHERE id = eventA;
  PERFORM vibetype_test.invoker_set_previous();

  SELECT count(*) INTO outbox_count
    FROM vibetype_private.outbox
    WHERE aggregate_type = 'event'
      AND aggregate_id = eventA
      AND type = 'event'
      AND payload = jsonb_build_object('id', eventA, 'type', 'event', 'op', 'u');

  IF outbox_count != 1 THEN
    RAISE EXCEPTION 'Test failed (event_outbox_update): expected 1 outbox event, got %', outbox_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_outbox_update;

-- Test that deleting an event publishes an outbox event with op 'd'
SAVEPOINT event_outbox_delete;
DO $$
DECLARE
  accountA UUID;
  eventA UUID;
  outbox_count INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  eventA := vibetype_test.event_create(accountA, 'Test Event', 'test-event', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(accountA);
  DELETE FROM vibetype.event WHERE id = eventA;
  PERFORM vibetype_test.invoker_set_previous();

  SELECT count(*) INTO outbox_count
    FROM vibetype_private.outbox
    WHERE aggregate_type = 'event'
      AND aggregate_id = eventA
      AND type = 'event'
      AND payload = jsonb_build_object('id', eventA, 'type', 'event', 'op', 'd');

  IF outbox_count != 1 THEN
    RAISE EXCEPTION 'Test failed (event_outbox_delete): expected 1 outbox event, got %', outbox_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_outbox_delete;

ROLLBACK;
