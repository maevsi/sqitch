BEGIN;

CREATE OR REPLACE FUNCTION vibetype.invite(guest_id uuid, language text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _contact RECORD;
  _guest RECORD;
BEGIN
  -- Guest UUID
  SELECT * INTO _guest FROM vibetype.guest WHERE guest.id = invite.guest_id;

  IF (
    _guest IS NULL
    OR
    NOT EXISTS ( -- Initial validation, every query below is expected to be secure.
      SELECT 1
      FROM vibetype.event e
      WHERE e.id = _guest.event_id
        AND e.created_by = vibetype.invoker_account_id()
    )
  ) THEN
    RAISE 'Guest not accessible!' USING ERRCODE = 'no_data_found';
  END IF;

  -- Contact
  SELECT account_id, email_address, contact.language INTO _contact FROM vibetype.contact WHERE contact.id = _guest.contact_id;

  IF (_contact IS NULL) THEN
    RAISE 'Contact not accessible!' USING ERRCODE = 'no_data_found';
  END IF;

  IF (_contact.account_id IS NULL) THEN
    IF (_contact.email_address IS NULL) THEN
      RAISE 'Contact email address not accessible!' USING ERRCODE = 'no_data_found';
    END IF;
  ELSIF (NOT EXISTS (SELECT 1 FROM vibetype_private.account WHERE account.id = _contact.account_id)) THEN
    RAISE 'Account email address not accessible!' USING ERRCODE = 'no_data_found';
  END IF;

  PERFORM vibetype_private.outbox_insert(
    'guest',
    _guest.id,
    'guest.invited',
    jsonb_build_object(
      'guest_id', _guest.id,
      'event_id', _guest.event_id,
      'contact_id', _guest.contact_id,
      'invited_by', vibetype.invoker_account_id(),
      'language', COALESCE(_contact.language::text, invite.language)
    )
  );
END;
$$;

COMMENT ON FUNCTION vibetype.invite(UUID, TEXT) IS 'Adds an outbox event of type `guest.invited`.\n\nError codes:\n- **P0002** when the guest, contact, the contact email address, or the account email address is not accessible.';

COMMIT;
