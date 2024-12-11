-- Verify maevsi:view_invitation_flat on pg

BEGIN;

SELECT
  id, contact_id, event_id, feedback, feedback_paper,
  contact_account_id, contact_address, contact_author_account_id,
  contact_email_address, contact_email_address_hash,
  contact_first_name, contact_last_name, contact_phone_number, contact_url,
  event_author_account_id, event_description,
  event_start, event_end, event_invitee_count_maximum,
  event_is_archived, event_is_in_person, event_is_remote,
  event_location, event_name, event_slug, event_url, event_visibility
FROM maevsi.invitation_flat WHERE FALSE;

ROLLBACK;
