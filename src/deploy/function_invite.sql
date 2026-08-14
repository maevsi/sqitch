BEGIN;

CREATE FUNCTION vibetype.invite(guest_id uuid, language text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _contact RECORD;
  _email_address TEXT;
  _event RECORD;
  _guest RECORD;
  _outbox_id UUID := public.gen_random_uuid();
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

  -- Event
  SELECT
    id,
    address_id,
    description,
    "end",
    guest_count_maximum,
    is_archived,
    is_in_person,
    is_remote,
    name,
    slug,
    start,
    url,
    visibility,
    created_at,
    created_by
  INTO _event
  FROM vibetype.event
  WHERE "event".id = _guest.event_id;

  IF (_event IS NULL) THEN
    RAISE 'Event not accessible!' USING ERRCODE = 'no_data_found';
  END IF;

  -- Contact
  SELECT account_id, email_address, contact.language, time_zone INTO _contact FROM vibetype.contact WHERE contact.id = _guest.contact_id;

  IF (_contact IS NULL) THEN
    RAISE 'Contact not accessible!' USING ERRCODE = 'no_data_found';
  END IF;

  IF (_contact.account_id IS NULL) THEN
    IF (_contact.email_address IS NULL) THEN
      RAISE 'Contact email address not accessible!' USING ERRCODE = 'no_data_found';
    ELSE
      _email_address := _contact.email_address;
    END IF;
  ELSE
    -- Account
    SELECT email_address INTO _email_address FROM vibetype_private.account WHERE account.id = _contact.account_id;

    IF (_email_address IS NULL) THEN
      RAISE 'Account email address not accessible!' USING ERRCODE = 'no_data_found';
    END IF;
  END IF;

  INSERT INTO vibetype_private.outbox (id, aggregate_type, aggregate_id, type, payload)
    VALUES (
      _outbox_id,
      'guest',
      _guest.id,
      'guest.invited',
      jsonb_build_object(
        'id', _outbox_id,
        'guest_id', _guest.id,
        'type', 'guest.invited',
        'template', jsonb_build_object('language', COALESCE(_contact.language::text, invite.language))
      )
    );
END;
$$;

COMMENT ON FUNCTION vibetype.invite(UUID, TEXT) IS 'Adds an outbox event of type "guest.invited".\n\nError codes:\n- **P0002** when the guest, event, contact, the contact email address, or the account email address is not accessible.';

GRANT EXECUTE ON FUNCTION vibetype.invite(UUID, TEXT) TO vibetype_account;

COMMIT;
