\echo test_outbox_acknowledge...

BEGIN;

-- Test that a freshly inserted outbox event is not acknowledged
SAVEPOINT outbox_is_acknowledged_default;
DO $$
DECLARE
  outbox_id UUID;
  result BOOLEAN;
BEGIN
  INSERT INTO vibetype_private.outbox (aggregate_type, aggregate_id, type, payload)
    VALUES ('event', gen_random_uuid(), 'event', '{}')
    RETURNING id INTO outbox_id;

  result := vibetype.outbox_is_acknowledged(outbox_id);

  IF result IS DISTINCT FROM FALSE THEN
    RAISE EXCEPTION 'Test failed (outbox_is_acknowledged_default): expected false, got %', result;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_is_acknowledged_default;

-- Test that acknowledging an outbox event is reflected by outbox_is_acknowledged
SAVEPOINT outbox_is_acknowledged_after_ack;
DO $$
DECLARE
  outbox_id UUID;
  result BOOLEAN;
BEGIN
  INSERT INTO vibetype_private.outbox (aggregate_type, aggregate_id, type, payload)
    VALUES ('event', gen_random_uuid(), 'event', '{}')
    RETURNING id INTO outbox_id;

  PERFORM vibetype.outbox_acknowledge(outbox_id, TRUE);
  result := vibetype.outbox_is_acknowledged(outbox_id);

  IF result IS DISTINCT FROM TRUE THEN
    RAISE EXCEPTION 'Test failed (outbox_is_acknowledged_after_ack): expected true, got %', result;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_is_acknowledged_after_ack;

-- Test that a missing outbox event id returns null
SAVEPOINT outbox_is_acknowledged_missing;
DO $$
DECLARE
  result BOOLEAN;
BEGIN
  result := vibetype.outbox_is_acknowledged(gen_random_uuid());

  IF result IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed (outbox_is_acknowledged_missing): expected null, got %', result;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_is_acknowledged_missing;

-- Test that acknowledging a missing outbox event id raises
SAVEPOINT outbox_acknowledge_missing;
DO $$
BEGIN
  BEGIN
    PERFORM vibetype.outbox_acknowledge(gen_random_uuid(), TRUE);
    RAISE EXCEPTION 'Test failed (outbox_acknowledge_missing): missing outbox event id accepted';
  EXCEPTION
    WHEN no_data_found THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT outbox_acknowledge_missing;

ROLLBACK;
