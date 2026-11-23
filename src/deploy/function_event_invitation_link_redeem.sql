BEGIN;

-- SECURITY DEFINER: the guest is inserted for an event the invoker may not see, with a contact the organizer owns when the invoker has no account.
CREATE FUNCTION vibetype.event_invitation_link_redeem(invitation_link_id UUID, email_address TEXT DEFAULT NULL, first_name TEXT DEFAULT NULL) RETURNS UUID
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
DECLARE
  _account_id UUID := vibetype.invoker_account_id();
  _contact_id UUID;
  _event_created_by UUID;
  _event_effective_end TIMESTAMP WITH TIME ZONE;
  _event_id UUID;
  _guest_id UUID;
BEGIN
  SELECT e.id, e.created_by, e.effective_end
  INTO _event_id, _event_created_by, _event_effective_end
  FROM vibetype.event_by_invitation_link(event_invitation_link_redeem.invitation_link_id) e;

  IF _event_id IS NULL THEN
    RAISE 'The invitation link does not exist.' USING ERRCODE = 'VTILN';
  END IF;

  IF _event_effective_end <= CURRENT_TIMESTAMP THEN
    RAISE 'The event has ended.' USING ERRCODE = 'VTEEN';
  END IF;

  IF _account_id IS NOT NULL THEN
    SELECT c.id INTO _contact_id
    FROM vibetype.contact c
    WHERE c.created_by = _account_id
      AND c.account_id = _account_id;

    SELECT g.id INTO _guest_id
    FROM vibetype.guest g
    WHERE g.event_id = _event_id
      AND g.contact_id = _contact_id;

    IF _guest_id IS NOT NULL THEN
      RETURN _guest_id;
    END IF;
  ELSE
    IF event_invitation_link_redeem.email_address IS NULL OR event_invitation_link_redeem.first_name IS NULL THEN
      RAISE 'An email address and a first name are required without an account.' USING ERRCODE = 'VTIDM';
    END IF;

    -- A new contact every time, as reusing one by its email address would hand its guests and details to whoever types that address.
    INSERT INTO vibetype.contact (created_by, email_address, first_name)
    VALUES (_event_created_by, event_invitation_link_redeem.email_address, event_invitation_link_redeem.first_name)
    RETURNING id INTO _contact_id;
  END IF;

  INSERT INTO vibetype.guest (contact_id, event_id, feedback)
  VALUES (_contact_id, _event_id, 'accepted')
  RETURNING id INTO _guest_id;

  RETURN _guest_id;
END;
$$;

COMMENT ON FUNCTION vibetype.event_invitation_link_redeem(UUID, TEXT, TEXT) IS E'@turnstileProtected\nJoins the event of a general invitation link as a guest who accepted, and returns the guest''s id. An account joins with its own contact and gets its existing guest back if it already joined. Without an account, the email address and first name become a new contact of the organizer.\n\nError codes:\n- **VTILN** when the invitation link does not exist.\n- **VTEEN** when the event has ended.\n- **VTIDM** when an email address or first name is missing without an account.\n- **VTGCM** when the event''s maximum guest count is reached.';

GRANT EXECUTE ON FUNCTION vibetype.event_invitation_link_redeem(UUID, TEXT, TEXT) TO vibetype_account, vibetype_anonymous;

COMMIT;
