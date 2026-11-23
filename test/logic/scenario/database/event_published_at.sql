\echo test_event_published_at...

BEGIN;

SAVEPOINT event_published_at_trigger;
DO $$
DECLARE
  accountA UUID;
  eventA UUID;
  _past TIMESTAMPTZ := CURRENT_TIMESTAMP - INTERVAL '1 day';
  _future TIMESTAMPTZ := CURRENT_TIMESTAMP + INTERVAL '1 day';
  _value TIMESTAMPTZ;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  -- insert with a past value
  INSERT INTO vibetype.event (name, slug, start, visibility, created_by, published_at)
  VALUES ('Past', 'past', '2025-06-01 20:00', 'public', accountA, _past)
  RETURNING id, published_at INTO eventA, _value;
  IF _value IS DISTINCT FROM CURRENT_TIMESTAMP THEN
    RAISE EXCEPTION 'Test failed (event_published_at_trigger): an inserted past value should be replaced by now, got %', _value;
  END IF;
  DELETE FROM vibetype.event WHERE id = eventA;

  -- insert with NULL and future values
  INSERT INTO vibetype.event (name, slug, start, visibility, created_by, published_at)
  VALUES ('Null', 'null', '2025-06-01 20:00', 'public', accountA, NULL)
  RETURNING published_at INTO _value;
  IF _value IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed (event_published_at_trigger): an inserted NULL should be kept, got %', _value;
  END IF;

  INSERT INTO vibetype.event (name, slug, start, visibility, created_by, published_at)
  VALUES ('Future', 'future', '2025-06-01 20:00', 'public', accountA, _future)
  RETURNING id, published_at INTO eventA, _value;
  IF _value IS DISTINCT FROM _future THEN
    RAISE EXCEPTION 'Test failed (event_published_at_trigger): an inserted future value should be kept, got %', _value;
  END IF;

  -- updates
  UPDATE vibetype.event SET published_at = _past WHERE id = eventA RETURNING published_at INTO _value;
  IF _value IS DISTINCT FROM CURRENT_TIMESTAMP THEN
    RAISE EXCEPTION 'Test failed (event_published_at_trigger): an updated past value should be clamped to now, got %', _value;
  END IF;

  -- an existing past value survives updates of other columns and of itself
  -- force an old value in place, bypassing the trigger
  ALTER TABLE vibetype.event DISABLE TRIGGER published_at;
  UPDATE vibetype.event SET published_at = _past WHERE id = eventA;
  ALTER TABLE vibetype.event ENABLE TRIGGER published_at;

  UPDATE vibetype.event SET name = 'Renamed' WHERE id = eventA RETURNING published_at INTO _value;
  IF _value IS DISTINCT FROM _past THEN
    RAISE EXCEPTION 'Test failed (event_published_at_trigger): an old value should survive other updates, got %', _value;
  END IF;

  UPDATE vibetype.event SET published_at = _past WHERE id = eventA RETURNING published_at INTO _value;
  IF _value IS DISTINCT FROM _past THEN
    RAISE EXCEPTION 'Test failed (event_published_at_trigger): an unchanged old value should be kept, got %', _value;
  END IF;

  UPDATE vibetype.event SET published_at = NULL WHERE id = eventA RETURNING published_at INTO _value;
  IF _value IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed (event_published_at_trigger): an updated NULL should be kept, got %', _value;
  END IF;

  UPDATE vibetype.event SET published_at = _future WHERE id = eventA RETURNING published_at INTO _value;
  IF _value IS DISTINCT FROM _future THEN
    RAISE EXCEPTION 'Test failed (event_published_at_trigger): an updated future value should be kept, got %', _value;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_published_at_trigger;

ROLLBACK;
