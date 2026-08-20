\echo test_contact_email_address...

BEGIN;

-- The contact's creator can read the contact_email_address link and the underlying email_address
-- row for a contact they created.
SAVEPOINT contact_email_address_select_own;
DO $$
DECLARE
  accountA UUID;
  contactAB UUID;
  _email_address_id UUID;
  _row_count INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  SELECT email_address_id INTO _email_address_id FROM vibetype.contact_email_address WHERE contact_id = contactAB;
  IF _email_address_id IS NULL THEN
    RAISE EXCEPTION 'Test failed (contact_email_address_select_own): creator could not read own contact_email_address row';
  END IF;

  SELECT count(*) INTO _row_count FROM vibetype_private.email_address WHERE id = _email_address_id;
  IF _row_count != 1 THEN
    RAISE EXCEPTION 'Test failed (contact_email_address_select_own): creator could not read own email_address row; row_count=%', _row_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_email_address_select_own;

-- Regression test: a guest reading their own invite (via a guest claim, not as the contact's
-- creator) must be able to read the contact_email_address link and email_address row through
-- vibetype.guest_contact_ids(), the same way they can already read the contact itself
-- (table_contact_policy.sql's contact_select). Before this fix, RLS silently hid this data,
-- even though the guest could see the contact row it belongs to.
SAVEPOINT contact_email_address_select_guest_claim;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
  _email_address_id UUID;
  _row_count INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  PERFORM vibetype_test.invoker_set(accountA);
  SELECT email_address_id INTO _email_address_id FROM vibetype.contact_email_address WHERE contact_id = contactAB;

  -- Simulate account B reading its own invite through a guest claim, not as contactAB's creator.
  PERFORM vibetype_test.invoker_set(accountB);
  PERFORM vibetype_test.guest_claim_set(accountB);

  SELECT count(*) INTO _row_count FROM vibetype.contact_email_address WHERE contact_id = contactAB;
  IF _row_count != 1 THEN
    RAISE EXCEPTION 'Test failed (contact_email_address_select_guest_claim): guest could not read contact_email_address row for their own invite; row_count=%', _row_count;
  END IF;

  SELECT count(*) INTO _row_count FROM vibetype_private.email_address WHERE id = _email_address_id;
  IF _row_count != 1 THEN
    RAISE EXCEPTION 'Test failed (contact_email_address_select_guest_claim): guest could not read email_address row for their own invite; row_count=%', _row_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_email_address_select_guest_claim;

-- An unrelated account (neither the contact's creator nor an invited guest) must not see the
-- contact_email_address link or the email_address row.
SAVEPOINT contact_email_address_select_unrelated;
DO $$
DECLARE
  accountA UUID;
  accountC UUID;
  contactAB UUID;
  _email_address_id UUID;
  _row_count INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');

  PERFORM vibetype_test.invoker_set(accountA);
  SELECT email_address_id INTO _email_address_id FROM vibetype.contact_email_address WHERE contact_id = contactAB;

  PERFORM vibetype_test.invoker_set(accountC);

  SELECT count(*) INTO _row_count FROM vibetype.contact_email_address WHERE contact_id = contactAB;
  IF _row_count != 0 THEN
    RAISE EXCEPTION 'Test failed (contact_email_address_select_unrelated): unrelated account could read contact_email_address row; row_count=%', _row_count;
  END IF;

  SELECT count(*) INTO _row_count FROM vibetype_private.email_address WHERE id = _email_address_id;
  IF _row_count != 0 THEN
    RAISE EXCEPTION 'Test failed (contact_email_address_select_unrelated): unrelated account could read email_address row; row_count=%', _row_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_email_address_select_unrelated;

-- A guest may read their own invite's email link (tested above), but must not be able to modify
-- or delete it; only the contact's creator has write access (contact_email_address_insert/
-- update/delete).
SAVEPOINT contact_email_address_guest_claim_readonly;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
  updated_count INTEGER;
  deleted_count INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  PERFORM vibetype_test.invoker_set(accountB);
  PERFORM vibetype_test.guest_claim_set(accountB);

  UPDATE vibetype.contact_email_address SET is_primary = TRUE WHERE contact_id = contactAB;
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  IF updated_count != 0 THEN
    RAISE EXCEPTION 'Test failed (contact_email_address_guest_claim_readonly): guest was able to update contact_email_address row; updated_count=%', updated_count;
  END IF;

  DELETE FROM vibetype.contact_email_address WHERE contact_id = contactAB;
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  IF deleted_count != 0 THEN
    RAISE EXCEPTION 'Test failed (contact_email_address_guest_claim_readonly): guest was able to delete contact_email_address row; deleted_count=%', deleted_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_email_address_guest_claim_readonly;

ROLLBACK;
