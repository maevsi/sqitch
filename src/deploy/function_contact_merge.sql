BEGIN;

-- SECURITY DEFINER: the invoker may not update `guest.contact_id` or `attendance.contact_id`, which the merge moves to the kept contact.
CREATE FUNCTION vibetype.contact_merge(contact vibetype.contact, contact_id_merged UUID) RETURNS vibetype.contact
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
DECLARE
  _account_id UUID := vibetype.invoker_account_id();
  _blocked UUID[] := vibetype_private.account_block_ids();
  _kept vibetype.contact;
  _merged vibetype.contact;
  _result vibetype.contact;
BEGIN
  SELECT * INTO _kept
  FROM vibetype.contact c
  WHERE c.id = contact_merge.contact.id
    AND c.created_by = _account_id
    AND (c.account_id IS NULL OR NOT (c.account_id = ANY (_blocked)))
  FOR UPDATE;

  SELECT * INTO _merged
  FROM vibetype.contact c
  WHERE c.id = contact_merge.contact_id_merged
    AND c.created_by = _account_id
    AND (c.account_id IS NULL OR NOT (c.account_id = ANY (_blocked)))
  FOR UPDATE;

  IF _kept.id IS NULL OR _merged.id IS NULL OR _kept.id = _merged.id THEN
    RAISE 'Both contacts must be distinct contacts of yours.' USING ERRCODE = 'VTCMN';
  END IF;

  IF _kept.account_id = _account_id OR _merged.account_id = _account_id THEN
    RAISE 'Your own account''s contact cannot be merged.' USING ERRCODE = 'VTCMS';
  END IF;

  IF _kept.account_id <> _merged.account_id THEN
    RAISE 'Contacts of two different accounts cannot be merged.' USING ERRCODE = 'VTCMA';
  END IF;

  IF contact_merge.contact.account_id IS DISTINCT FROM COALESCE(_kept.account_id, _merged.account_id)
    OR (
      contact_merge.contact.address_id IS NOT NULL
      AND contact_merge.contact.address_id IS DISTINCT FROM _kept.address_id
      AND contact_merge.contact.address_id IS DISTINCT FROM _merged.address_id
    )
  THEN
    RAISE 'The account and address must be taken from either contact.' USING ERRCODE = 'VTCMV';
  END IF;

  IF EXISTS (
    SELECT 1
    FROM vibetype.guest g_kept
    JOIN vibetype.guest g_merged ON g_merged.event_id = g_kept.event_id
    WHERE g_kept.contact_id = _kept.id
      AND g_merged.contact_id = _merged.id
  ) THEN
    RAISE 'Both contacts are guests of the same event.' USING ERRCODE = 'VTCMG';
  END IF;

  UPDATE vibetype.guest SET contact_id = _kept.id WHERE guest.contact_id = _merged.id;
  UPDATE vibetype.attendance SET contact_id = _kept.id WHERE attendance.contact_id = _merged.id;

  INSERT INTO vibetype.contact_group_member (contact_group_id, contact_id)
  SELECT m.contact_group_id, _kept.id
  FROM vibetype.contact_group_member m
  WHERE m.contact_id = _merged.id
  ON CONFLICT DO NOTHING;

  -- Deleted before the update, as the unique constraint on `created_by` and `account_id` would reject the kept contact taking over the merged contact's account.
  DELETE FROM vibetype.contact WHERE id = _merged.id;

  UPDATE vibetype.contact SET
    account_id = contact_merge.contact.account_id,
    address_id = contact_merge.contact.address_id,
    email_addresses = contact_merge.contact.email_addresses,
    first_name = contact_merge.contact.first_name,
    language = contact_merge.contact.language,
    last_name = contact_merge.contact.last_name,
    nickname = contact_merge.contact.nickname,
    note = contact_merge.contact.note,
    phone_number = contact_merge.contact.phone_number,
    time_zone = contact_merge.contact.time_zone,
    url = contact_merge.contact.url
  WHERE id = _kept.id
  RETURNING * INTO _result;

  RETURN _result;
END;
$$;

COMMENT ON FUNCTION vibetype.contact_merge(vibetype.contact, UUID) IS E'Merges a contact into another one of yours and returns the kept contact. The kept contact is identified by the given contact''s `id` and takes over its other fields, so the caller picks each value. The merged contact''s guests, attendances and group memberships move to the kept contact, so existing invitations stay valid, and the merged contact is deleted.\n\nError codes:\n- **VTCMN** when either contact is not one of yours or both are the same.\n- **VTCMS** when either contact is your own account''s contact.\n- **VTCMA** when the contacts refer to two different accounts.\n- **VTCMV** when the account or address is not taken from either contact.\n- **VTCMG** when both contacts are guests of the same event.';

GRANT EXECUTE ON FUNCTION vibetype.contact_merge(vibetype.contact, UUID) TO vibetype_account;

COMMIT;
