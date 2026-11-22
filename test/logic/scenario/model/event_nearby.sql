\echo test_event_nearby...

BEGIN;

SAVEPOINT event_nearby_basic;
DO $$
DECLARE
  _account UUID;
  _near UUID;
  _nearer UUID;
  _far UUID;
  _result UUID[];
BEGIN
  _account := vibetype_test.account_registration_verified('a', 'a@example.com');

  _near := vibetype_test.event_create(_account, 'Near', 'near', '2099-06-01 20:00', 'public');
  _nearer := vibetype_test.event_create(_account, 'Nearer', 'nearer', '2099-06-01 20:00', 'public');
  _far := vibetype_test.event_create(_account, 'Far', 'far', '2099-06-01 20:00', 'public');
  PERFORM vibetype_test.invoker_set(_account);
  UPDATE vibetype.event SET is_in_person = TRUE WHERE id IN (_near, _nearer, _far);
  PERFORM vibetype_test.event_update_address_coordinates(_near, 50.005, 8.0); -- about 550 m north
  PERFORM vibetype_test.event_update_address_coordinates(_nearer, 50.001, 8.0); -- about 110 m north
  PERFORM vibetype_test.event_update_address_coordinates(_far, 50.1, 8.0); -- about 11 km north

  PERFORM vibetype_test.invoker_set(_account);

  _result := ARRAY(SELECT id FROM vibetype.event_nearby(50.0, 8.0, 1000));
  IF _result IS DISTINCT FROM ARRAY[_nearer, _near] THEN
    RAISE EXCEPTION 'Test failed (event_nearby_basic): expected nearest first without the far event, got %', _result;
  END IF;

  _result := ARRAY(SELECT id FROM vibetype.event_nearby(50.0, 8.0, 200));
  IF _result IS DISTINCT FROM ARRAY[_nearer] THEN
    RAISE EXCEPTION 'Test failed (event_nearby_basic): radius 200 m should only return the nearer event, got %', _result;
  END IF;

  IF (SELECT distance FROM vibetype.event_nearby_match(50.0, 8.0, 1000) WHERE event_id = _nearer) NOT BETWEEN 100 AND 120 THEN
    RAISE EXCEPTION 'Test failed (event_nearby_basic): distance should be about 111 m';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_nearby_basic;

SAVEPOINT event_nearby_excluded;
DO $$
DECLARE
  _account UUID;
  _private UUID;
  _unpublished UUID;
  _archived UUID;
  _remote UUID;
  _unset UUID;
  _public UUID;
  _result UUID[];
BEGIN
  _account := vibetype_test.account_registration_verified('a', 'a@example.com');

  _private := vibetype_test.event_create(_account, 'Private', 'private', '2099-06-01 20:00', 'private');
  _unpublished := vibetype_test.event_create(_account, 'Unpublished', 'unpublished', '2099-06-01 20:00', 'public');
  _archived := vibetype_test.event_create(_account, 'Archived', 'archived', '2099-06-01 20:00', 'public');
  _remote := vibetype_test.event_create(_account, 'Remote', 'remote', '2099-06-01 20:00', 'public');
  _unset := vibetype_test.event_create(_account, 'Unset', 'unset', '2099-06-01 20:00', 'public');
  _public := vibetype_test.event_create(_account, 'Public', 'public', '2099-06-01 20:00', 'public');
  PERFORM vibetype_test.invoker_set(_account);
  UPDATE vibetype.event SET is_in_person = TRUE WHERE id IN (_private, _unpublished, _archived, _public);
  UPDATE vibetype.event SET is_in_person = FALSE WHERE id = _remote;
  UPDATE vibetype.event SET is_archived = TRUE WHERE id = _archived;
  UPDATE vibetype.event SET is_published = FALSE WHERE id = _unpublished;
  PERFORM vibetype_test.event_update_address_coordinates(_private, 50.0, 8.0);
  PERFORM vibetype_test.event_update_address_coordinates(_unpublished, 50.0, 8.0);
  PERFORM vibetype_test.event_update_address_coordinates(_archived, 50.0, 8.0);
  PERFORM vibetype_test.event_update_address_coordinates(_remote, 50.0, 8.0);
  PERFORM vibetype_test.event_update_address_coordinates(_unset, 50.0, 8.0);
  PERFORM vibetype_test.event_update_address_coordinates(_public, 50.001, 8.0);

  -- even the creator of a private or unpublished event does not get it back
  PERFORM vibetype_test.invoker_set(_account);
  _result := ARRAY(SELECT id FROM vibetype.event_nearby(50.0, 8.0, 1000));
  IF _result IS DISTINCT FROM ARRAY[_public] THEN
    RAISE EXCEPTION 'Test failed (event_nearby_excluded): only the public in-person event should be returned, got %', _result;
  END IF;

  -- the matcher itself must not leak private or unpublished events either
  IF EXISTS (SELECT 1 FROM vibetype.event_nearby_match(50.0, 8.0, 1000) WHERE event_id <> _public) THEN
    RAISE EXCEPTION 'Test failed (event_nearby_excluded): matcher returned an event other than the public in-person one';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_nearby_excluded;

SAVEPOINT event_nearby_include_ended;
DO $$
DECLARE
  _account UUID;
  _ended UUID;
  _upcoming UUID;
  _result UUID[];
BEGIN
  _account := vibetype_test.account_registration_verified('a', 'a@example.com');

  _ended := vibetype_test.event_create(_account, 'Ended', 'ended', '2000-01-01 20:00', 'public');
  _upcoming := vibetype_test.event_create(_account, 'Upcoming', 'upcoming', '2099-06-01 20:00', 'public');
  PERFORM vibetype_test.invoker_set(_account);
  UPDATE vibetype.event SET is_in_person = TRUE WHERE id IN (_ended, _upcoming);
  PERFORM vibetype_test.event_update_address_coordinates(_ended, 50.0, 8.0);
  PERFORM vibetype_test.event_update_address_coordinates(_upcoming, 50.001, 8.0);

  PERFORM vibetype_test.invoker_set(_account);

  _result := ARRAY(SELECT id FROM vibetype.event_nearby(50.0, 8.0, 1000));
  IF _result IS DISTINCT FROM ARRAY[_upcoming] THEN
    RAISE EXCEPTION 'Test failed (event_nearby_include_ended): ended event should be excluded by default, got %', _result;
  END IF;

  _result := ARRAY(SELECT id FROM vibetype.event_nearby(50.0, 8.0, 1000, include_ended => true));
  IF _result IS DISTINCT FROM ARRAY[_ended, _upcoming] THEN
    RAISE EXCEPTION 'Test failed (event_nearby_include_ended): ended event should be included when asked, got %', _result;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_nearby_include_ended;

SAVEPOINT event_nearby_block;
DO $$
DECLARE
  _account_a UUID;
  _account_b UUID;
  _event UUID;
BEGIN
  _account_a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _account_b := vibetype_test.account_registration_verified('b', 'b@example.com');

  _event := vibetype_test.event_create(_account_b, 'Blocked', 'blocked', '2099-06-01 20:00', 'public');
  PERFORM vibetype_test.invoker_set(_account_b);
  UPDATE vibetype.event SET is_in_person = TRUE WHERE id = _event;
  PERFORM vibetype_test.event_update_address_coordinates(_event, 50.0, 8.0);

  PERFORM vibetype_test.invoker_set(_account_a);
  IF NOT EXISTS (SELECT 1 FROM vibetype.event_nearby(50.0, 8.0, 1000)) THEN
    RAISE EXCEPTION 'Test failed (event_nearby_block): public event should be found before blocking';
  END IF;

  PERFORM vibetype_test.account_block_create(_account_a, _account_b);

  PERFORM vibetype_test.invoker_set(_account_a);
  IF EXISTS (SELECT 1 FROM vibetype.event_nearby(50.0, 8.0, 1000)) THEN
    RAISE EXCEPTION 'Test failed (event_nearby_block): event of a blocked account should not be returned';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_nearby_block;

SAVEPOINT event_nearby_anonymous;
DO $$
BEGIN
  PERFORM vibetype_test.invoker_set_anonymous();

  BEGIN
    PERFORM vibetype.event_nearby(50.0, 8.0, 1000);
    RAISE EXCEPTION 'Test failed (event_nearby_anonymous): anonymous invoker was able to call event_nearby.';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
  END;

  BEGIN
    PERFORM vibetype.event_nearby_match(50.0, 8.0, 1000);
    RAISE EXCEPTION 'Test failed (event_nearby_anonymous): anonymous invoker was able to call event_nearby_match.';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
  END;
END $$;
ROLLBACK TO SAVEPOINT event_nearby_anonymous;

ROLLBACK;
