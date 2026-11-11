BEGIN;

ALTER TABLE vibetype.guest ADD COLUMN is_ghost BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN vibetype.guest.is_ghost IS E'@behavior -insert\nWhether the guest takes part without appearing among the event''s attendees. Only the guest''s own account can change it.';

GRANT UPDATE (is_ghost) ON TABLE vibetype.guest TO vibetype_account;

-- `guest_update` also lets the organizer update a guest, who must not decide about the guest's visibility.
CREATE FUNCTION vibetype.trigger_guest_is_ghost() RETURNS TRIGGER
    LANGUAGE plpgsql STRICT
    AS $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM vibetype.contact c
    WHERE c.id = NEW.contact_id
      AND c.account_id = vibetype.invoker_account_id()
  ) THEN
    RAISE 'Only the guest''s own account is allowed to change the ghost mode!' USING ERRCODE = 'insufficient_privilege';
  END IF;

  RETURN NEW;
END $$;

COMMENT ON FUNCTION vibetype.trigger_guest_is_ghost() IS 'Checks that a guest''s ghost mode is changed by the guest''s own account only.';

GRANT EXECUTE ON FUNCTION vibetype.trigger_guest_is_ghost() TO vibetype_account;

CREATE TRIGGER is_ghost
  BEFORE UPDATE OF is_ghost
  ON vibetype.guest
  FOR EACH ROW
  WHEN (NEW.is_ghost IS DISTINCT FROM OLD.is_ghost)
  EXECUTE FUNCTION vibetype.trigger_guest_is_ghost();

COMMIT;
