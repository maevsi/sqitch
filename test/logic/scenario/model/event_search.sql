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
  searchResults := ARRAY(SELECT id FROM vibetype.event_search('summer'));

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
  searchResults := ARRAY(SELECT id FROM vibetype.event_search('party'));

  IF NOT (eventA = ANY(searchResults)) THEN
    RAISE EXCEPTION 'Test failed: search for "party" should include Birthday Party event';
  END IF;

  -- Search for both events with general term
  searchResults := ARRAY(SELECT id FROM vibetype.event_search('celebration'));

  IF NOT (eventB = ANY(searchResults)) THEN
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
  searchResults := ARRAY(SELECT id FROM vibetype.event_search('nonexistentterm'));

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

  -- The event's `language` column is never set by `vibetype_test.event_create()` (stays NULL), so this
  -- also covers searching an event whose language differs from (or is unknown relative to) the query.
  -- Search using an English word.
  searchResults := ARRAY(SELECT id FROM vibetype.event_search('event'));

  IF NOT (eventA = ANY(searchResults)) THEN
    RAISE EXCEPTION 'Test failed: search should find event via its English word';
  END IF;

  -- Search using a German word, stemmed differently than English (Veranstaltungen -> Veranstaltung).
  searchResults := ARRAY(SELECT id FROM vibetype.event_search('Veranstaltungen'));

  IF NOT (eventA = ANY(searchResults)) THEN
    RAISE EXCEPTION 'Test failed: search should find event via a German-stemmed plural';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_search_language;

SAVEPOINT event_search_prefix;
DO $$
DECLARE
  accountA UUID;
  eventA UUID;
  searchResults UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  eventA := vibetype_test.event_create(accountA, 'Jazz Concert', 'jazz-concert', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(accountA);

  -- Search for an incomplete word, as typed live in a search box.
  searchResults := ARRAY(SELECT id FROM vibetype.event_search('conc'));

  IF NOT (eventA = ANY(searchResults)) THEN
    RAISE EXCEPTION 'Test failed: search for "conc" should match "Concert" by prefix';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_search_prefix;

SAVEPOINT event_search_typo;
DO $$
DECLARE
  accountA UUID;
  eventA UUID;
  searchResults UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  eventA := vibetype_test.event_create(accountA, 'Jazz Concert', 'jazz-concert', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(accountA);

  -- Search with a typo in the name, falling back to trigram similarity.
  searchResults := ARRAY(SELECT id FROM vibetype.event_search('Comcert'));

  IF NOT (eventA = ANY(searchResults)) THEN
    RAISE EXCEPTION 'Test failed: search for "Comcert" should match "Concert" via typo tolerance';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_search_typo;

SAVEPOINT event_search_rank_configs_covered;
DO $$
DECLARE
  _derived_configs regconfig[];
  _handled_configs regconfig[] := ARRAY['german', 'english', 'simple']::regconfig[];
BEGIN
  SELECT ARRAY(
    SELECT DISTINCT vibetype.language_iso_full_text_search(language)
    FROM unnest(enum_range(NULL::vibetype.language)) AS language
    UNION
    SELECT 'simple'::regconfig
  ) INTO _derived_configs;

  IF NOT (_derived_configs <@ _handled_configs) THEN
    RAISE EXCEPTION 'Test failed: vibetype.language_iso_full_text_search() now produces % which vibetype.event_search_rank() does not have a matching OR branch for (it only handles %). Add a matching literal branch to event_search_rank()''s WHERE clause in function_event_search.sql.', _derived_configs, _handled_configs;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_search_rank_configs_covered;

SAVEPOINT event_search_anonymous;
DO $$
BEGIN
  PERFORM vibetype_test.invoker_set_anonymous();

  BEGIN
    PERFORM vibetype.event_search('a');
    RAISE EXCEPTION 'Test failed (event_search_anonymous): anonymous invoker was able to search events.';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT event_search_anonymous;

ROLLBACK;
