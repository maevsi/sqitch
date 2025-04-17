\echo test_invitation...

BEGIN;

DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  
  contactAB UUID;
  contactAC UUID;
  eventA UUID;
  
  guest_ids UUID[];

  rec RECORD;

BEGIN

  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
    
  PERFORM vibetype_test.invoker_set(accountA);
  
  guest_ids := ARRAY(SELECT id FROM vibetype.create_guests(eventA, ARRAY[contactAB, contactAC]));

  PERFORM vibetype_test.invoker_unset();
  
  PERFORM vibetype_test.guest_create_multiple_test('create multiple guest records', accountA, eventA, ARRAY[contactAB, contactAC], guest_ids);

END $$ LANGUAGE plpgsql;
  
ROLLBACK;