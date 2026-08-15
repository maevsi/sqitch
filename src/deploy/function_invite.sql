BEGIN;

CREATE FUNCTION vibetype.invite(guest_id uuid, language text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _contact RECORD;
  _email_address TEXT;
  _subject_id UUID;
  _event RECORD;
  _event_creator_profile_picture_upload_id UUID;
  _event_creator_profile_picture_upload_storage_key TEXT;
  _event_creator_username TEXT;
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
  SELECT id, account_id, contact.language, time_zone INTO _contact FROM vibetype.contact WHERE contact.id = _guest.contact_id;

  IF (_contact.id IS NULL) THEN
    RAISE 'Contact not accessible!' USING ERRCODE = 'no_data_found';
  END IF;

  -- Prefer the linked account's own verified email; fall back to the contact's own listed email.
  IF (_contact.account_id IS NOT NULL) THEN
    SELECT ea.address, ea.subject_id INTO _email_address, _subject_id
      FROM vibetype_private.account_email_address aea
      JOIN vibetype_private.email_address ea ON ea.id = aea.email_address_id
      WHERE aea.account_id = _contact.account_id AND aea.is_primary;
  END IF;

  IF (_email_address IS NULL) THEN
    SELECT ea.address, ea.subject_id INTO _email_address, _subject_id
      FROM vibetype.contact_email_address cea
      JOIN vibetype_private.email_address ea ON ea.id = cea.email_address_id
      WHERE cea.contact_id = _guest.contact_id AND cea.is_primary;
  END IF;

  IF (_email_address IS NULL) THEN
    RAISE 'Contact email address not accessible!' USING ERRCODE = 'no_data_found';
  END IF;

  -- Event creator username
  SELECT username INTO _event_creator_username FROM vibetype.account WHERE account.id = _event.created_by;

  -- Event creator profile picture storage key
  SELECT upload_id INTO _event_creator_profile_picture_upload_id FROM vibetype.profile_picture WHERE profile_picture.account_id = _event.created_by;
  SELECT storage_key INTO _event_creator_profile_picture_upload_storage_key FROM vibetype.upload WHERE upload.id = _event_creator_profile_picture_upload_id;

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
        'contact_time_zone', _contact.time_zone,
        'event', jsonb_build_object(
          'id', _event.id,
          'address_id', _event.address_id,
          'description', _event.description,
          'end', _event."end",
          'guest_count_maximum', _event.guest_count_maximum,
          'is_archived', _event.is_archived,
          'is_in_person', _event.is_in_person,
          'is_remote', _event.is_remote,
          'name', _event.name,
          'slug', _event.slug,
          'start', _event.start,
          'url', _event.url,
          'visibility', _event.visibility,
          'created_at', _event.created_at,
          'created_by', _event.created_by
        ),
        'encrypted', encode(vibetype_private.outbox_encrypt(_subject_id, jsonb_build_object(
          'contactEmailAddress', _email_address,
          'eventCreatorProfilePictureUploadStorageKey', _event_creator_profile_picture_upload_storage_key,
          'eventCreatorUsername', _event_creator_username
        )), 'base64'),
        'template', jsonb_build_object('language', COALESCE(_contact.language::text, invite.language))
      )
    );
END;
$$;

COMMENT ON FUNCTION vibetype.invite(UUID, TEXT) IS 'Adds an outbox event of type "guest.invited".\n\nError codes:\n- **P0002** when the guest, event, or contact is not accessible, or no email address can be resolved for the contact.';

GRANT EXECUTE ON FUNCTION vibetype.invite(UUID, TEXT) TO vibetype_account;

COMMIT;
