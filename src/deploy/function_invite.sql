-- Deploy maevsi:function_account_delete to pg
-- requires: privilege_execute_revoke
-- requires: schema_public
-- requires: table_invitation
-- requires: function_events_organized
-- requires: table_event
-- requires: table_contact
-- requires: schema_private
-- requires: table_account_private
-- requires: table_profile_picture
-- requires: table_notification
-- requires: role_account

BEGIN;

CREATE FUNCTION maevsi.invite(
  invitation_id UUID,
  "language" TEXT
) RETURNS VOID AS $$
DECLARE
  _contact RECORD;
  _email_address TEXT;
  _event RECORD;
  _event_author_profile_picture_upload_id UUID;
  _event_author_profile_picture_upload_storage_key TEXT;
  _event_author_username TEXT;
  _invitation RECORD;
BEGIN
  -- Invitation UUID
  SELECT * FROM maevsi.invitation INTO _invitation WHERE invitation.id = $1;

  IF (
    _invitation IS NULL
    OR
    _invitation.event_id NOT IN (SELECT maevsi.events_organized()) -- Initial validation, every query below is expected to be secure.
  ) THEN
    RAISE 'Invitation not accessible!' USING ERRCODE = 'no_data_found';
  END IF;

  -- Event
  SELECT * FROM maevsi.event INTO _event WHERE "event".id = _invitation.event_id;

  IF (_event IS NULL) THEN
    RAISE 'Event not accessible!' USING ERRCODE = 'no_data_found';
  END IF;

  -- Contact
  SELECT account_id, email_address FROM maevsi.contact INTO _contact WHERE contact.id = _invitation.contact_id;

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

  -- Event author username
  SELECT username FROM maevsi.account INTO _event_author_username WHERE account.id = _event.author_account_id;

  -- Event author profile picture storage key
  SELECT upload_id FROM maevsi.profile_picture INTO _event_author_profile_picture_upload_id WHERE profile_picture.account_id = _event.author_account_id;
  SELECT storage_key FROM maevsi.upload INTO _event_author_profile_picture_upload_storage_key WHERE upload.id = _event_author_profile_picture_upload_id;

  INSERT INTO maevsi_private.notification (channel, payload)
    VALUES (
      'event_invitation',
      jsonb_pretty(jsonb_build_object(
        'data', jsonb_build_object(
          'emailAddress', _email_address,
          'event', _event,
          'eventAuthorProfilePictureUploadStorageKey', _event_author_profile_picture_upload_storage_key,
          'eventAuthorUsername', _event_author_username,
          'invitationId', _invitation.id
        ),
        'template', jsonb_build_object('language', $2)
      ))
    );
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.invite(UUID, TEXT) IS 'Adds a notification for the invitation channel.';

GRANT EXECUTE ON FUNCTION maevsi.invite(UUID, TEXT) TO maevsi_account;

COMMIT;
