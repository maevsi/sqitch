BEGIN;

SELECT
  invitation_id,
  invitation_contact_id,
  invitation_event_id,
  invitation_feedback,
  invitation_feedback_paper,
  contact_id,
  contact_account_id,
  contact_address,
  contact_email_address,
  contact_email_address_hash,
  contact_first_name,
  contact_last_name,
  contact_phone_number,
  contact_url,
  contact_created_by,
  event_id,
  event_description,
  event_start,
  event_end,
  event_invitee_count_maximum,
  event_is_archived,
  event_is_in_person,
  event_is_remote,
  event_location,
  event_name,
  event_slug,
  event_url,
  event_visibility,
  event_created_by
FROM maevsi.invitation_flat WHERE FALSE;

ROLLBACK;
