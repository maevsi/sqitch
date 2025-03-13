BEGIN;

CREATE FUNCTION maevsi.invite(
  guest_id UUID,
  "language" TEXT
) RETURNS UUID AS $$
DECLARE
  _contact RECORD;
  _email_address TEXT;
  _event RECORD;
  _event_creator_profile_picture_upload_storage_key TEXT;
  _event_creator_username TEXT;
  _guest RECORD;
  _id UUID;
BEGIN
  -- Guest UUID
  SELECT * INTO _guest
  FROM maevsi.guest
  WHERE guest.id = invite.guest_id;

  IF (
    _guest IS NULL
    OR
    _guest.event_id NOT IN (SELECT maevsi.events_organized()) -- Initial validation, every query below is expected to be secure.
  ) THEN
    RAISE 'Guest not accessible!' USING ERRCODE = 'no_data_found';
  END IF;

  -- Event
  SELECT * INTO _event FROM maevsi.event WHERE id = _guest.event_id;

  IF (_event IS NULL) THEN
    RAISE 'Event not accessible!' USING ERRCODE = 'no_data_found';
  END IF;

  -- Contact
  SELECT account_id, email_address INTO _contact
  FROM maevsi.contact
  WHERE id = _guest.contact_id;

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
    SELECT email_address INTO _email_address
    FROM maevsi_private.account
    WHERE id = _contact.account_id;

    IF (_email_address IS NULL) THEN
      RAISE 'Account email address not accessible!' USING ERRCODE = 'no_data_found';
    END IF;
  END IF;

  -- Event creator username
  SELECT username INTO _event_creator_username
  FROM maevsi.account
  WHERE id = _event.created_by;

  -- Event creator profile picture storage key
  SELECT u.storage_key INTO _event_creator_profile_picture_upload_storage_key
  FROM maevsi.profile_picture p
    JOIN maevsi.upload u ON p.upload_id = u.id
  WHERE p.account_id = _event.created_by;

  INSERT INTO maevsi.invitation (guest_id, channel, payload, created_by)
    VALUES (
      invite.guest_id,
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
      )),
      maevsi.invoker_account_id()
    )
    RETURNING id INTO _id;

    RETURN _id;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.invite(UUID, TEXT) IS 'Adds an invitation and a notification.';

GRANT EXECUTE ON FUNCTION maevsi.invite(UUID, TEXT) TO maevsi_account;

COMMIT;
