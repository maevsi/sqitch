BEGIN;

CREATE OR REPLACE FUNCTION vibetype.trigger_upload_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
DECLARE
  _current_usage BIGINT;
  _quota BIGINT;
BEGIN
  SELECT COALESCE(SUM(size_byte), 0)
    INTO _current_usage
    FROM vibetype.upload
    WHERE created_by = NEW.created_by;

  SELECT upload_quota_bytes
    INTO _quota
    FROM vibetype_private.account
    WHERE id = NEW.created_by;

  IF (_current_usage + NEW.size_byte) > _quota THEN
    RAISE 'Upload quota limit reached!' USING ERRCODE = 'disk_full';
  END IF;

  RETURN NEW;
END;
$$;

COMMIT;
