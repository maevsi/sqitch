\echo test_event_search...

-- make sure the client encoding matches the encoding of database tables
\encoding UTF8

BEGIN;

DO $$
DECLARE
  accountA  UUID;
  event1    UUID;
  event2    UUID;
  supported_languages vibetype.language[];
  number_of_supported_languages INTEGER;
  rec       RECORD;
  _language vibetype.language;
  _query    TEXT;
  event_rec vibetype.event%ROWTYPE;
  
BEGIN

  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  event1 := vibetype_test.event_create(accountA, 'Event 1', 'event-1', 'This is the perfect place for all lonely hearts.', 'en'::vibetype.language, '2025-07-01 20:00', 'public');
  event2 := vibetype_test.event_create(accountA, 'Event 2', 'event-2', 'Die besten Tänze machen den Abend zu einem unvergesslichen Erlebnis.', 'de'::vibetype.language, '2025-07-01 20:00', 'public');

  supported_languages := enum_range(NULL::vibetype.language);
  number_of_supported_languages := array_length(supported_languages, 1);
  
  FOR rec IN
    SELECT event_id, count(*) n
    FROM vibetype.event_search_vector
    WHERE event_id IN (event1, event2)
    GROUP BY event_id
    HAVING count(*) <> number_of_supported_languages
  LOOP
    RAISE EXCEPTION '%: number of text vectors does not match the number of available languages', rec.event_id;
  END LOOP;

/*
  FOR rec IN
    SELECT e.name, e.description, esv.language, esv.search_vector
    FROM vibetype.event e JOIN vibetype.event_search_vector esv ON e.id = esv.event_id
    WHERE e.id IN (event1, event2)
  LOOP
    RAISE NOTICE '%, %, %, %', rec.name, rec.description, rec.language, rec.search_vector;
  END LOOP;
*/

  -- english text search vectors contain 'heart' and 'Tänze'
  -- german text search vectors contain 'heart' and 'tanz'

  FOREACH _language IN ARRAY supported_languages
  LOOP
    FOREACH _query IN ARRAY ARRAY['heart', 'hearts', 'tanz', 'tänze']
    LOOP
        SELECT * INTO event_rec 
        FROM vibetype.event_search(_query, _language);
        
        IF _query = 'tanz' and _language = 'en' THEN
          -- query result should be empty
          IF event_rec.id IS NOT NULL THEN
            RAISE EXCEPTION 'query result should be empty';
          END IF;
        ELSE
          -- query result should not be empty
          IF _query IN ('heart', 'hearts') AND event_rec.id != event1 THEN
            RAISE EXCEPTION 'id in result should have been %', event1;
          ELSEIF _query IN ('tanz', 'tänze') AND event_rec.id != event2 THEN
            RAISE EXCEPTION 'id in result should have been %', event2;
          END IF;
        END IF;
    
    END LOOP;
  END LOOP;

END $$;

ROLLBACK;
