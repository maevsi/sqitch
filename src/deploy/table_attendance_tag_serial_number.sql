BEGIN;

ALTER TABLE vibetype.attendance
  ADD COLUMN tag_serial_number TEXT CHECK (char_length(tag_serial_number) <= 100);

-- Only the organizer may set it, which the guard below enforces for guests, who may update an attendance to check out.
GRANT UPDATE (tag_serial_number) ON TABLE vibetype.attendance TO vibetype_account;

COMMENT ON COLUMN vibetype.attendance.tag_serial_number IS 'The serial number of the physical tag written for this entry, which tells a tag apart from a copy that carries the same link.';

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

    -- A guest binding their entry to another tag would make a copied tag pass as the original.
    IF NEW.tag_serial_number IS DISTINCT FROM OLD.tag_serial_number THEN
      RAISE EXCEPTION 'tag_serial_number can only be modified by the organizer' USING ERRCODE = 'insufficient_privilege';
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

COMMIT;
