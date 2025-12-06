BEGIN;

CREATE FUNCTION vibetype.invite(guest_id uuid, language text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _contact RECORD;
  _email_address TEXT;
  _event RECORD;
  _event_creator_profile_picture_upload_id UUID;
  _event_creator_profile_picture_upload_storage_key TEXT;
  _event_creator_username TEXT;
  _guest RECORD;
BEGIN
  -- Guest UUID
  SELECT * INTO _guest FROM vibetype.guest WHERE guest.id = invite.guest_id;

  IF (
    _guest IS NULL
    OR
    NOT EXISTS ( -- Initial validation, every query below is expected to be secure.
      SELECT 1
      FROM vibetype.events_organized() eo(event_id)
      WHERE eo.event_id = _guest.event_id
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
  SELECT account_id, email_address INTO _contact FROM vibetype.contact WHERE contact.id = _guest.contact_id;

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

  -- Event creator username
  SELECT username INTO _event_creator_username FROM vibetype.account WHERE account.id = _event.created_by;

  -- Event creator profile picture storage key
  SELECT upload_id INTO _event_creator_profile_picture_upload_id FROM vibetype.profile_picture WHERE profile_picture.account_id = _event.created_by;
  SELECT storage_key INTO _event_creator_profile_picture_upload_storage_key FROM vibetype.upload WHERE upload.id = _event_creator_profile_picture_upload_id;

  INSERT INTO vibetype_private.notification (channel, payload)
    VALUES (
      'event_invitation',
      jsonb_pretty(jsonb_build_object(
        'data', jsonb_build_object(
          'emailAddress', _email_address,
          'event', _event,
          'eventCreatorProfilePictureUploadStorageKey', _event_creator_profile_picture_upload_storage_key,
          'eventCreatorUsername', _event_creator_username,
          'guestId', _guest.id
        ),
        'template', jsonb_build_object('language', invite.language)
      ))
    );
END;
$$;

COMMENT ON FUNCTION vibetype.invite(UUID, TEXT) IS 'Adds a notification for the invitation channel.\n\nError codes:\n- **P0002** when the guest, event, contact, the contact email address, or the account email address is not accessible.';

GRANT EXECUTE ON FUNCTION vibetype.invite(UUID, TEXT) TO vibetype_account;

COMMIT;
