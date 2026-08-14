BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

CREATE FUNCTION vibetype.outbox_payload_guest_invitation(guest_id uuid) RETURNS TABLE (
  contact_email_address text,
  contact_time_zone text,
  event jsonb,
  event_creator_profile_picture_upload_storage_key text,
  event_creator_username text
)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT
    COALESCE(a.email_address, c.email_address),
    c.time_zone,
    jsonb_build_object(
      'id', e.id,
      'addressId', e.address_id,
      'description', e.description,
      'end', e."end",
      'guestCountMaximum', e.guest_count_maximum,
      'isArchived', e.is_archived,
      'isInPerson', e.is_in_person,
      'isRemote', e.is_remote,
      'name', e.name,
      'slug', e.slug,
      'start', e.start,
      'url', e.url,
      'visibility', e.visibility,
      'createdAt', e.created_at,
      'createdBy', e.created_by
    ),
    up.storage_key,
    ea.username
  FROM vibetype.guest g
  JOIN vibetype.contact c ON c.id = g.contact_id
  LEFT JOIN vibetype_private.account a ON a.id = c.account_id
  JOIN vibetype.event e ON e.id = g.event_id
  JOIN vibetype.account ea ON ea.id = e.created_by
  LEFT JOIN vibetype.profile_picture pp ON pp.account_id = e.created_by
  LEFT JOIN vibetype.upload up ON up.id = pp.upload_id
  WHERE g.id = outbox_payload_guest_invitation.guest_id;
$$;

COMMENT ON FUNCTION vibetype.outbox_payload_guest_invitation(UUID) IS 'Fetches the contact, event and event creator data needed to compose a guest invitation email, keyed by guest id. Kept out of the outbox payload itself so this personal data never reaches the CDC log.';

GRANT EXECUTE ON FUNCTION vibetype.outbox_payload_guest_invitation(UUID) TO :role_service_vibetype_username;

COMMIT;
