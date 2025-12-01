\echo test_event_search...

BEGIN;

SAVEPOINT event_search_basic;
DO $$
DECLARE
  accountA UUID;
  eventA UUID;
  eventB UUID;
  eventC UUID;
  searchResults UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  eventA := vibetype_test.event_create(accountA, 'Summer Party', 'summer-party', '2025-06-01 20:00', 'public');
  eventB := vibetype_test.event_create(accountA, 'Winter Gala', 'winter-gala', '2025-12-01 19:00', 'public');
  eventC := vibetype_test.event_create(accountA, 'Spring Festival', 'spring-festival', '2025-03-01 15:00', 'public');

  PERFORM vibetype_test.invoker_set(accountA);

  -- Search for "summer"
  searchResults := ARRAY(SELECT id FROM vibetype.event_search('summer', 'en'));

  IF NOT (eventA = ANY(searchResults)) THEN
    RAISE EXCEPTION 'Test failed: search for "summer" should include Summer Party event';
  END IF;

  IF eventB = ANY(searchResults) THEN
    RAISE EXCEPTION 'Test failed: search for "summer" should not include Winter Gala event';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_search_basic;

SAVEPOINT event_search_multiple_words;
DO $$
DECLARE
  accountA UUID;
  eventA UUID;
  eventB UUID;
  searchResults UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  eventA := vibetype_test.event_create(accountA, 'Birthday Party', 'birthday-party', '2025-06-01 20:00', 'public');
  eventB := vibetype_test.event_create(accountA, 'Anniversary Celebration', 'anniversary', '2025-07-01 18:00', 'public');

  PERFORM vibetype_test.invoker_set(accountA);

  -- Search for "party"
  searchResults := ARRAY(SELECT id FROM vibetype.event_search('party', NULL)); -- TODO: set language param (https://github.com/maevsi/sqitch/issues/164)

  IF NOT (eventA = ANY(searchResults)) THEN
    RAISE EXCEPTION 'Test failed: search for "party" should include Birthday Party event';
  END IF;

  -- Search for both events with general term
  searchResults := ARRAY(SELECT id FROM vibetype.event_search('celebration', NULL)); -- TODO: set language param (https://github.com/maevsi/sqitch/issues/164)

  IF eventA = ANY(searchResults) AND eventB = ANY(searchResults) THEN
    -- Both might match if there's stemming
    NULL;
  ELSIF eventB = ANY(searchResults) THEN
    -- At least anniversary should match
    NULL;
  ELSE
    RAISE EXCEPTION 'Test failed: search for "celebration" should return at least Anniversary event';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_search_multiple_words;

SAVEPOINT event_search_empty;
DO $$
DECLARE
  accountA UUID;
  eventA UUID;
  searchResults UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  eventA := vibetype_test.event_create(accountA, 'Test Event', 'test-event', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(accountA);

  -- Search for non-existent term
  searchResults := ARRAY(SELECT id FROM vibetype.event_search('nonexistentterm', 'en'));

  IF array_length(searchResults, 1) > 0 THEN
    RAISE EXCEPTION 'Test failed: search for non-existent term should return empty results';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_search_empty;

SAVEPOINT event_search_language;
DO $$
DECLARE
  accountA UUID;
  eventA UUID;
  searchResults UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  eventA := vibetype_test.event_create(accountA, 'German Event Veranstaltung', 'german-event', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(accountA);

  -- Search with English language
  searchResults := ARRAY(SELECT id FROM vibetype.event_search('event', 'en'));

  IF NOT (eventA = ANY(searchResults)) THEN
    RAISE EXCEPTION 'Test failed: search should find event with English language';
  END IF;

  -- Search with German language
  searchResults := ARRAY(SELECT id FROM vibetype.event_search('event', 'de'));

  IF NOT (eventA = ANY(searchResults)) THEN
    RAISE EXCEPTION 'Test failed: search should find event with German language';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_search_language;

ROLLBACK;
