BEGIN;

DO $$
DECLARE
  accountA UUID;
  accountB UUID;

  contactAB UUID;
  eventA UUID;
  guestAB UUID;

  invitationId UUID;

  rec RECORD;

BEGIN

  accountA := maevsi_test.account_create('a', 'a@example.com');
  accountB := maevsi_test.account_create('b', 'b@example.com');
  contactAB := maevsi_test.contact_create(accountA, 'b@example.com');
  eventA := maevsi_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  guestAB := maevsi_test.guest_create(accountA, eventA, contactAB);

  PERFORM maevsi_test.invoker_set(accountA);

  invitationId := maevsi.invite(guestAB, 'de');

  SELECT guest_id, created_by, channel INTO rec
  FROM maevsi.invitation
  WHERE id = invitationId;

  IF rec.guest_id != guestAB or rec.created_by != accountA or rec.channel != 'event_invitation' THEN
    RAISE EXCEPTION 'The invitation was not correctly created';
  END IF;

END $$;

ROLLBACK;