\echo test_invitation...

BEGIN;

DO $$
DECLARE
  accountA UUID;
  accountB UUID;

  contactAB UUID;
  eventA UUID;
  guestAB UUID;

  payload JSONB;

BEGIN

  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  PERFORM vibetype_test.outbox_capture();
  PERFORM vibetype_test.invoker_set(accountA);

  PERFORM vibetype.invite(guestAB, 'de');

  PERFORM vibetype_test.invoker_set_previous();

  payload := vibetype_test.outbox_payload('guest.invited', guestAB);

  IF payload -> 'data' IS DISTINCT FROM jsonb_build_object(
    'guest_id', guestAB,
    'event_id', eventA,
    'contact_id', contactAB,
    'invited_by', accountA,
    'language', 'de'
  ) THEN
    RAISE EXCEPTION 'The invitation was not correctly created';
  END IF;

END $$ LANGUAGE plpgsql;

ROLLBACK;
