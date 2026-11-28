\echo test_event_feedback_deadline...

BEGIN;

SAVEPOINT event_feedback_deadline_future;
DO $$
DECLARE
  _count INTEGER;
  accountA UUID;
  accountB UUID;
  eventA UUID;
  guestBA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  guestBA := vibetype_test.guest_create(accountB, eventA, vibetype_test.contact_select_by_account_id(accountB));

  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.event SET feedback_deadline = CURRENT_TIMESTAMP + INTERVAL '1 day' WHERE id = eventA;

  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET feedback = 'accepted' WHERE id = guestBA;
  GET DIAGNOSTICS _count = ROW_COUNT;

  PERFORM vibetype_test.invoker_set_previous();

  IF _count <> 1 THEN
    RAISE EXCEPTION 'Test failed: a guest should give feedback before the deadline';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_feedback_deadline_future;

SAVEPOINT event_feedback_deadline_passed;
DO $$
DECLARE
  _count INTEGER;
  accountA UUID;
  accountB UUID;
  accountC UUID;
  eventA UUID;
  guestBA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  guestBA := vibetype_test.guest_create(accountB, eventA, vibetype_test.contact_select_by_account_id(accountB));

  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.event SET feedback_deadline = CURRENT_TIMESTAMP - INTERVAL '1 day' WHERE id = eventA;

  PERFORM vibetype_test.invoker_set(accountB);

  BEGIN
    UPDATE vibetype.guest SET feedback = 'accepted' WHERE id = guestBA;
    RAISE EXCEPTION 'Test failed: a guest should not give feedback after the deadline';
  EXCEPTION WHEN SQLSTATE 'VTFDP' THEN
    NULL;
  END;

  PERFORM vibetype_test.invoker_set(accountC);

  BEGIN
    INSERT INTO vibetype.guest(contact_id, event_id, feedback)
    VALUES (vibetype_test.contact_select_by_account_id(accountC), eventA, 'accepted');
    RAISE EXCEPTION 'Test failed: an event should not be joined with feedback after the deadline';
  EXCEPTION WHEN SQLSTATE 'VTFDP' THEN
    NULL;
  END;

  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.guest SET feedback_override = 'canceled' WHERE id = guestBA;
  GET DIAGNOSTICS _count = ROW_COUNT;

  PERFORM vibetype_test.invoker_set_previous();

  IF _count <> 1 THEN
    RAISE EXCEPTION 'Test failed: the organizer should change feedback after the deadline';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_feedback_deadline_passed;

ROLLBACK;
