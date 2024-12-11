-- Verify maevsi:view_invitation_flat on pg

BEGIN;

SELECT
  id, contact_id, event_id, feedback, feedback_paper,
  contact_account_id, address, contact_author_account_id, email_address, email_address_hash,
  first_name, last_name, phone_number, contact_url,
  event_author_account_id, description, "start", "end",
  invitee_count_maximum, is_archived, is_in_person, is_remote,
  location, name, slug, event_url, visibility
FROM maevsi.invitation_flat WHERE FALSE;

ROLLBACK;
