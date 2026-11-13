\echo test_event_guest_count_database...

BEGIN;

-- The migration backfills existing events; replay it on an event whose counter was reset.
SAVEPOINT event_guest_count_backfill;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  eventA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');
  PERFORM vibetype_test.guest_create(accountA, eventA, contactAB);

  ALTER TABLE vibetype.guest DISABLE TRIGGER guest_count_insert;
  PERFORM vibetype_test.guest_create(accountA, eventA, vibetype_test.contact_create(accountA, 'c@example.com'));
  ALTER TABLE vibetype.guest ENABLE TRIGGER guest_count_insert;

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 1 THEN
    RAISE EXCEPTION 'Test failed: setup must leave the counter behind';
  END IF;

  UPDATE vibetype.event
  SET guest_count = g.guest_count
  FROM (SELECT event_id, COUNT(*)::INTEGER AS guest_count FROM vibetype.guest GROUP BY event_id) g
  WHERE event.id = g.event_id;

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 2 THEN
    RAISE EXCEPTION 'Test failed: the backfill query must restore the counter';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_guest_count_backfill;

-- Updates that only move the counter leave no audit log entry, other updates still do.
SAVEPOINT event_guest_count_audit_log;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
  _count BIGINT;
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM vibetype_private.audit_log_trigger WHERE schema_name = 'vibetype' AND table_name = 'event'
  ) THEN
    PERFORM vibetype_private.trigger_audit_log_create('vibetype', 'event');
  END IF;

  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');

  SELECT count(*) INTO _count FROM vibetype_private.audit_log WHERE table_name = 'event' AND record_id = eventA::TEXT;

  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  PERFORM vibetype_test.invoker_set(accountA);
  DELETE FROM vibetype.guest WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  IF (SELECT count(*) FROM vibetype_private.audit_log WHERE table_name = 'event' AND record_id = eventA::TEXT) != _count THEN
    RAISE EXCEPTION 'Test failed: counter updates must not be audited';
  END IF;

  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.event SET name = 'Renamed' WHERE id = eventA;
  PERFORM vibetype_test.invoker_set_previous();

  IF (SELECT count(*) FROM vibetype_private.audit_log WHERE table_name = 'event' AND record_id = eventA::TEXT) != _count + 1 THEN
    RAISE EXCEPTION 'Test failed: other event updates must still be audited';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_guest_count_audit_log;

ROLLBACK;
