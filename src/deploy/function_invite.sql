BEGIN;

CREATE FUNCTION maevsi.invite(
  guest_id UUID,
  language TEXT
) RETURNS VOID AS $$
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
  SELECT * FROM maevsi.guest INTO _guest WHERE guest.id = invite.guest_id;

  IF (
    _guest IS NULL
    OR
    _guest.event_id NOT IN (SELECT maevsi.events_organized()) -- Initial validation, every query below is expected to be secure.
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
  FROM maevsi.event INTO _event WHERE "event".id = _guest.event_id;

  IF (_event IS NULL) THEN
    RAISE 'Event not accessible!' USING ERRCODE = 'no_data_found';
  END IF;

  -- Contact
  SELECT account_id, email_address FROM maevsi.contact INTO _contact WHERE contact.id = _guest.contact_id;

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
    SELECT email_address FROM maevsi_private.account INTO _email_address WHERE account.id = _contact.account_id;

    IF (_email_address IS NULL) THEN
      RAISE 'Account email address not accessible!' USING ERRCODE = 'no_data_found';
    END IF;
  END IF;

  -- Event creator username
  SELECT username FROM maevsi.account INTO _event_creator_username WHERE account.id = _event.created_by;

  -- Event creator profile picture storage key
  SELECT upload_id FROM maevsi.profile_picture INTO _event_creator_profile_picture_upload_id WHERE profile_picture.account_id = _event.created_by;
  SELECT storage_key FROM maevsi.upload INTO _event_creator_profile_picture_upload_storage_key WHERE upload.id = _event_creator_profile_picture_upload_id;

  INSERT INTO maevsi_private.notification (channel, payload)
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
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.invite(UUID, TEXT) IS 'Adds a notification for the invitation channel.';

GRANT EXECUTE ON FUNCTION maevsi.invite(UUID, TEXT) TO maevsi_account;

COMMIT;
