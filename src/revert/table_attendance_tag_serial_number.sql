BEGIN;

CREATE OR REPLACE FUNCTION vibetype.attendance_guard() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    -- Allow organizer to modify entries freely
    IF EXISTS (
      SELECT 1
      FROM vibetype.guest g
      JOIN vibetype.event e ON e.id = g.event_id
      WHERE g.id = NEW.guest_id
        AND e.created_by = vibetype.invoker_account_id()
    ) THEN
      RETURN NEW;
    END IF;

    -- For non-organizers, allow checkout exactly once: transition from FALSE/NULL -> TRUE only
    IF NEW.checked_out IS DISTINCT FROM OLD.checked_out THEN
      IF OLD.checked_out IS TRUE THEN
        RAISE EXCEPTION 'checked_out cannot be modified once set' USING ERRCODE = 'data_exception';
      END IF;
      IF NEW.checked_out IS DISTINCT FROM TRUE THEN
        RAISE EXCEPTION 'checked_out must be set to true to check out' USING ERRCODE = 'data_exception';
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

ALTER TABLE vibetype.attendance DROP COLUMN tag_serial_number;

COMMIT;
