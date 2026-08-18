\echo test_outbox_processed...

BEGIN;

-- Test that a freshly inserted outbox event is not yet marked as processed.
SAVEPOINT outbox_is_processed_default;
DO $$
DECLARE
  outbox_id UUID;
  result BOOLEAN;
BEGIN
  INSERT INTO vibetype_private.outbox (aggregate_type, aggregate_id, type, payload)
    VALUES ('event', gen_random_uuid(), 'event', '{}')
    RETURNING id INTO outbox_id;

  result := vibetype.outbox_is_processed(outbox_id);

  IF result IS DISTINCT FROM FALSE THEN
    RAISE EXCEPTION 'Test failed (outbox_is_processed_default): expected false, got %', result;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_is_processed_default;

-- Test that marking an outbox event as processed is reflected by outbox_is_processed.
SAVEPOINT outbox_is_processed_after_mark;
DO $$
DECLARE
  outbox_id UUID;
  result BOOLEAN;
BEGIN
  INSERT INTO vibetype_private.outbox (aggregate_type, aggregate_id, type, payload)
    VALUES ('event', gen_random_uuid(), 'event', '{}')
    RETURNING id INTO outbox_id;

  PERFORM vibetype.outbox_mark_processed(outbox_id);
  result := vibetype.outbox_is_processed(outbox_id);

  IF result IS DISTINCT FROM TRUE THEN
    RAISE EXCEPTION 'Test failed (outbox_is_processed_after_mark): expected true, got %', result;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_is_processed_after_mark;

-- Test that marking an outbox event as processed twice does not raise, since two independent
-- consumers (or a retry) may race to mark the same id.
SAVEPOINT outbox_mark_processed_idempotent;
DO $$
DECLARE
  outbox_id UUID;
  result BOOLEAN;
BEGIN
  INSERT INTO vibetype_private.outbox (aggregate_type, aggregate_id, type, payload)
    VALUES ('event', gen_random_uuid(), 'event', '{}')
    RETURNING id INTO outbox_id;

  PERFORM vibetype.outbox_mark_processed(outbox_id);
  PERFORM vibetype.outbox_mark_processed(outbox_id);
  result := vibetype.outbox_is_processed(outbox_id);

  IF result IS DISTINCT FROM TRUE THEN
    RAISE EXCEPTION 'Test failed (outbox_mark_processed_idempotent): expected true, got %', result;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_mark_processed_idempotent;

-- Test that outbox_is_processed reports true for a processed marker even after its source outbox
-- row is gone, since the marker is deliberately not foreign-keyed to vibetype_private.outbox and
-- must outlive that table's retention purge.
SAVEPOINT outbox_is_processed_survives_outbox_purge;
DO $$
DECLARE
  outbox_id UUID;
  result BOOLEAN;
BEGIN
  INSERT INTO vibetype_private.outbox (aggregate_type, aggregate_id, type, payload)
    VALUES ('event', gen_random_uuid(), 'event', '{}')
    RETURNING id INTO outbox_id;

  PERFORM vibetype.outbox_mark_processed(outbox_id);
  DELETE FROM vibetype_private.outbox WHERE id = outbox_id;

  result := vibetype.outbox_is_processed(outbox_id);

  IF result IS DISTINCT FROM TRUE THEN
    RAISE EXCEPTION 'Test failed (outbox_is_processed_survives_outbox_purge): expected true, got %', result;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_is_processed_survives_outbox_purge;

ROLLBACK;
