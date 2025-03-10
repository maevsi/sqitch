BEGIN;

SELECT
  guest_id,
  guest_contact_id,
  guest_event_id,
  guest_feedback,
  guest_feedback_paper,
  contact_id,
  contact_account_id,
  contact_address_id,
  contact_email_address,
  contact_email_address_hash,
  contact_first_name,
  contact_last_name,
  contact_phone_number,
  contact_url,
  contact_created_by,
  event_id,
  event_address_id,
  event_description,
  event_start,
  event_end,
  event_guest_count_maximum,
  event_is_archived,
  event_is_in_person,
  event_is_remote,
  event_name,
  event_slug,
  event_url,
  event_visibility,
  event_created_by
FROM vibetype.guest_flat WHERE FALSE;

ROLLBACK;
