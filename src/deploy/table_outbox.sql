BEGIN;

CREATE TABLE vibetype_private.outbox (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  aggregate_type     TEXT NOT NULL,
  aggregate_id       UUID NOT NULL,
  type               TEXT NOT NULL,
  payload            JSONB NOT NULL,

  created_at         TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE vibetype_private.outbox IS 'A transactional outbox for domain events. Rows are deleted right after their insertion, so they only reach downstream consumers through change data capture of the write-ahead log.';
COMMENT ON COLUMN vibetype_private.outbox.id IS 'The outbox event''s internal id.';
COMMENT ON COLUMN vibetype_private.outbox.aggregate_type IS 'The kind of entity the event is about, e.g. `account`, `event`, `guest` or `upload`. Routes the event to the topic `vibetype.outbox.<aggregate_type>`.';
COMMENT ON COLUMN vibetype_private.outbox.aggregate_id IS 'The id of the entity the event is about. Used as message key, which keeps the order of events about the same entity.';
COMMENT ON COLUMN vibetype_private.outbox.type IS 'The event''s type in the form `<aggregate>.<past tense verb>`, e.g. `account.registered`.';
COMMENT ON COLUMN vibetype_private.outbox.payload IS 'The event''s envelope, which becomes the message value.';
COMMENT ON COLUMN vibetype_private.outbox.created_at IS 'The timestamp of the outbox event''s creation.';

CREATE FUNCTION vibetype_private.outbox_insert(aggregate_type text, aggregate_id uuid, type text, data jsonb, version integer DEFAULT 1) RETURNS void
    LANGUAGE sql
    AS $$
  INSERT INTO vibetype_private.outbox (id, aggregate_type, aggregate_id, type, payload)
  SELECT
    _outbox.id,
    outbox_insert.aggregate_type,
    outbox_insert.aggregate_id,
    outbox_insert.type,
    jsonb_build_object(
      'id', _outbox.id,
      'type', outbox_insert.type,
      'aggregate_type', outbox_insert.aggregate_type,
      'aggregate_id', outbox_insert.aggregate_id,
      'version', outbox_insert.version,
      'occurred_at', CURRENT_TIMESTAMP,
      'data', outbox_insert.data
    )
  FROM (SELECT gen_random_uuid() AS id) _outbox;
$$;

COMMENT ON FUNCTION vibetype_private.outbox_insert(TEXT, UUID, TEXT, JSONB, INTEGER) IS 'Adds an outbox event, wrapping its data in the envelope. The version is per type and must be bumped on any incompatible change to that type''s data.';

CREATE FUNCTION vibetype_private.trigger_outbox_delete() RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
BEGIN
  DELETE FROM vibetype_private.outbox WHERE id = NEW.id;
  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION vibetype_private.trigger_outbox_delete() IS 'Deletes an outbox event right after its insertion, as the write-ahead log already holds it for change data capture.';

CREATE TRIGGER delete
  AFTER INSERT
  ON vibetype_private.outbox
  FOR EACH ROW
  EXECUTE FUNCTION vibetype_private.trigger_outbox_delete();

COMMIT;
