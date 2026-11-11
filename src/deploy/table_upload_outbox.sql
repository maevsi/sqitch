BEGIN;

CREATE FUNCTION vibetype.trigger_upload_outbox() RETURNS TRIGGER
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
BEGIN
  PERFORM vibetype_private.outbox_insert('upload', OLD.id, 'upload.deleted', jsonb_build_object('storage_key', OLD.storage_key));

  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION vibetype.trigger_upload_outbox() IS 'Adds an outbox event of type `upload.deleted` with the upload''s storage key, which is needed for file cleanup.';

CREATE TRIGGER outbox
  AFTER DELETE
  ON vibetype.upload
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.trigger_upload_outbox();

-- Upload deletions reach change data capture through the outbox now.
ALTER TABLE vibetype.upload REPLICA IDENTITY DEFAULT;

COMMIT;
