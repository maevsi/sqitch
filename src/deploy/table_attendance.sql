BEGIN;

CREATE TABLE vibetype.attendance (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,

  checked_out   boolean,
  contact_id    uuid REFERENCES vibetype.contact(id) ON DELETE SET NULL,
  guest_id      uuid NOT NULL REFERENCES vibetype.guest(id) ON DELETE CASCADE,

  created_at    timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at    timestamp with time zone,
  updated_by    uuid REFERENCES vibetype.account(id) ON DELETE SET NULL,

  UNIQUE (guest_id)
);

CREATE INDEX idx_attendance_contact_id ON vibetype.attendance USING btree (contact_id);
CREATE INDEX idx_attendance_updated_by ON vibetype.attendance USING btree (updated_by);

COMMENT ON TABLE vibetype.attendance IS E'@omit delete\nKeeps track of when someone arrives and leaves an event. Each person can only be checked in once.';
COMMENT ON COLUMN vibetype.attendance.id IS E'@omit create,update\nA unique reference for this entry.';
COMMENT ON COLUMN vibetype.attendance.checked_out IS E'@omit create\nShows if the person has left. When this turns on, the time is saved automatically.';
COMMENT ON COLUMN vibetype.attendance.contact_id IS E'@omit update\nThe contact information available to anyone with access to this attendance entry. This may differ from the guest information if the guest provided different details at check-in.';
COMMENT ON COLUMN vibetype.attendance.guest_id IS E'@omit update\nWho this entry is for.';
COMMENT ON COLUMN vibetype.attendance.created_at IS E'@omit create,update\nWhen the entry was created (the check-in time).';
COMMENT ON COLUMN vibetype.attendance.updated_at IS E'@omit create,update\nWhen this entry was last changed. If someone checks out, this shows the checkout time.';
COMMENT ON COLUMN vibetype.attendance.updated_by IS E'@omit create,update\nWho last changed this entry. This may be empty if done without signing in.';
COMMENT ON INDEX vibetype.idx_attendance_contact_id IS 'Speeds up searching by contact.';
COMMENT ON INDEX vibetype.idx_attendance_updated_by IS 'Speeds up searching by who changed an entry.';

CREATE TRIGGER vibetype_trigger_attendance_metadata_update
  BEFORE UPDATE ON vibetype.attendance
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.trigger_metadata_update();


-- Guard to enforce one-time checkout
CREATE FUNCTION vibetype.attendance_guard() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
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
COMMENT ON FUNCTION vibetype.attendance_guard() IS 'Ensures that checking out can happen only once.';
GRANT EXECUTE ON FUNCTION vibetype.attendance_guard() TO vibetype_anonymous, vibetype_account;

CREATE TRIGGER vibetype_trigger_attendance_guard
  BEFORE UPDATE ON vibetype.attendance
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.attendance_guard();

-- GRANTs, RLS and POLICYs are specified in `table_attendance_policy`.

COMMIT;
