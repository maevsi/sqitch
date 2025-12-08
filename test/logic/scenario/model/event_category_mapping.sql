\echo test_event_category_mapping...

BEGIN;

SAVEPOINT event_category_mapping_select;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactAB UUID;
  contactAC UUID;
  contactBA UUID;
  contactBC UUID;
  contactCA UUID;
  contactCB UUID;
  eventA UUID;
  eventB UUID;
  eventC UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  contactBA := vibetype_test.contact_create(accountB, 'a@example.com');
  contactBC := vibetype_test.contact_create(accountB, 'c@example.com');
  contactCA := vibetype_test.contact_create(accountC, 'a@example.com');
  contactCB := vibetype_test.contact_create(accountC, 'b@example.com');

  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  eventB := vibetype_test.event_create(accountB, 'Event by B', 'event-by-b', '2025-06-01 20:00', 'public');
  eventC := vibetype_test.event_create(accountC, 'Event by C', 'event-by-c', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.event_category_create('category');
  PERFORM vibetype_test.event_category_mapping_create(accountA, eventA, 'category');
  PERFORM vibetype_test.event_category_mapping_create(accountB, eventB, 'category');
  PERFORM vibetype_test.event_category_mapping_create(accountC, eventC, 'category');

  PERFORM vibetype_test.event_category_mapping_test('event_category_mapping visibility without block (perspective A)', accountA, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM vibetype_test.event_category_mapping_test('event_category_mapping visibility without block (perspective B)', accountB, ARRAY[eventA, eventB, eventC]::UUID[]);
END $$;
ROLLBACK TO SAVEPOINT event_category_mapping_select;

SAVEPOINT event_category_mapping_select_block;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactAB UUID;
  contactAC UUID;
  contactBA UUID;
  contactBC UUID;
  contactCA UUID;
  contactCB UUID;
  eventA UUID;
  eventB UUID;
  eventC UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  contactBA := vibetype_test.contact_create(accountB, 'a@example.com');
  contactBC := vibetype_test.contact_create(accountB, 'c@example.com');
  contactCA := vibetype_test.contact_create(accountC, 'a@example.com');
  contactCB := vibetype_test.contact_create(accountC, 'b@example.com');

  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  eventB := vibetype_test.event_create(accountB, 'Event by B', 'event-by-b', '2025-06-01 20:00', 'public');
  eventC := vibetype_test.event_create(accountC, 'Event by C', 'event-by-c', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.event_category_create('category');
  PERFORM vibetype_test.event_category_mapping_create(accountA, eventA, 'category');
  PERFORM vibetype_test.event_category_mapping_create(accountB, eventB, 'category');
  PERFORM vibetype_test.event_category_mapping_create(accountC, eventC, 'category');

  PERFORM vibetype_test.account_block_create(accountA, accountB);

  PERFORM vibetype_test.event_category_mapping_test('event_category_mapping visibility with block (perspective A)', accountA, ARRAY[eventA, eventC]::UUID[]);
  PERFORM vibetype_test.event_category_mapping_test('event_category_mapping visibility with block (perspective B)', accountB, ARRAY[eventB, eventC]::UUID[]);
END $$;
ROLLBACK TO SAVEPOINT event_category_mapping_select_block;

ROLLBACK;
