BEGIN;

CREATE FUNCTION vibetype_private.guest_claim_contact_link(account_id UUID, guest_ids UUID[]) RETURNS INTEGER
    LANGUAGE plpgsql STRICT
    AS $$
DECLARE
  _blocked UUID[];
  _count INTEGER;
  _invoker_account_id TEXT := current_setting('jwt.claims.sub', true);
BEGIN
  -- The contact update trigger rejects updates without an invoker, and the blocks to respect are the account's, not the caller's.
  PERFORM set_config('jwt.claims.sub', guest_claim_contact_link.account_id::TEXT, true);
  _blocked := vibetype_private.account_block_ids();

  WITH _contact AS (
    SELECT DISTINCT ON (contact.created_by) contact.id
    FROM vibetype.guest
    INNER JOIN vibetype.contact ON contact.id = guest.contact_id
    INNER JOIN vibetype.event ON event.id = guest.event_id
    WHERE guest.id = ANY (guest_claim_contact_link.guest_ids)
      AND contact.account_id IS NULL
      AND NOT (contact.created_by = ANY (_blocked))
      AND NOT (event.created_by = ANY (_blocked))
      AND NOT EXISTS (
        SELECT 1
        FROM vibetype.contact existing
        WHERE existing.created_by = contact.created_by
          AND existing.account_id = guest_claim_contact_link.account_id
      )
    ORDER BY contact.created_by, contact.created_at
  )
  UPDATE vibetype.contact
  SET account_id = guest_claim_contact_link.account_id
  FROM _contact
  WHERE contact.id = _contact.id;

  GET DIAGNOSTICS _count = ROW_COUNT;

  PERFORM set_config('jwt.claims.sub', COALESCE(_invoker_account_id, ''), true);

  RETURN _count;
END;
$$;

COMMENT ON FUNCTION vibetype_private.guest_claim_contact_link(UUID, UUID[]) IS 'Links the contacts of the given guests to the given account, so their invitations outlast the session that claimed them. Skips a contact whose creator already has one for the account, which the unique constraint on `created_by` and `account_id` would reject, and the contacts of accounts the account blocks. Returns the number of linked contacts.';

COMMIT;
