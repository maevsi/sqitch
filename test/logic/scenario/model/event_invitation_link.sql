\echo test_event_invitation_link...

BEGIN;

-- Only the organizer sees and manages the link.
SAVEPOINT event_invitation_link_organizer;
DO $$
DECLARE
  _count INTEGER;
  _event_id UUID;
  _organizer_id UUID;
  _other_id UUID;
BEGIN
  _organizer_id := vibetype_test.account_registration_verified('organizer', 'organizer@example.com');
  _other_id := vibetype_test.account_registration_verified('other', 'other@example.com');
  _event_id := vibetype_test.event_create(_organizer_id, 'Event', 'event', '2099-01-01 20:00', 'private');

  PERFORM vibetype_test.invoker_set(_organizer_id);
  INSERT INTO vibetype.event_invitation_link (event_id) VALUES (_event_id);
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_other_id);
  SELECT count(*) INTO _count FROM vibetype.event_invitation_link;

  IF _count <> 0 THEN
    RAISE EXCEPTION 'Test failed: another account sees the invitation link';
  END IF;

  BEGIN
    INSERT INTO vibetype.event_invitation_link (event_id) VALUES (_event_id);
    RAISE EXCEPTION 'Test failed: another account created an invitation link';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT event_invitation_link_organizer;

-- The link reveals a private event to anonymous visitors, but not to accounts involved in a block with the organizer.
SAVEPOINT event_invitation_link_event;
DO $$
DECLARE
  _blocked_id UUID;
  _event_id UUID;
  _link_id UUID;
  _organizer_id UUID;
BEGIN
  _organizer_id := vibetype_test.account_registration_verified('organizer', 'organizer@example.com');
  _blocked_id := vibetype_test.account_registration_verified('blocked', 'blocked@example.com');
  _event_id := vibetype_test.event_create(_organizer_id, 'Event', 'event', '2099-01-01 20:00', 'private');
  PERFORM vibetype_test.account_block_create(_organizer_id, _blocked_id);

  PERFORM vibetype_test.invoker_set(_organizer_id);
  INSERT INTO vibetype.event_invitation_link (event_id) VALUES (_event_id) RETURNING id INTO _link_id;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set_anonymous();
  IF (vibetype.event_by_invitation_link(_link_id)).id IS DISTINCT FROM _event_id THEN
    RAISE EXCEPTION 'Test failed: the link does not reveal the event to an anonymous visitor';
  END IF;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_blocked_id);
  IF (vibetype.event_by_invitation_link(_link_id)).id IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: the link reveals the event to a blocked account';
  END IF;
  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT event_invitation_link_event;

-- An account joins with its own contact, and joining again returns the same guest.
SAVEPOINT event_invitation_link_redeem_account;
DO $$
DECLARE
  _account_id UUID;
  _event_id UUID;
  _guest_id UUID;
  _link_id UUID;
  _organizer_id UUID;
BEGIN
  _organizer_id := vibetype_test.account_registration_verified('organizer', 'organizer@example.com');
  _account_id := vibetype_test.account_registration_verified('guest', 'guest@example.com');
  _event_id := vibetype_test.event_create(_organizer_id, 'Event', 'event', '2099-01-01 20:00', 'private');

  PERFORM vibetype_test.invoker_set(_organizer_id);
  INSERT INTO vibetype.event_invitation_link (event_id) VALUES (_event_id) RETURNING id INTO _link_id;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_account_id);
  _guest_id := vibetype.event_invitation_link_redeem(_link_id);

  IF vibetype.event_invitation_link_redeem(_link_id) IS DISTINCT FROM _guest_id THEN
    RAISE EXCEPTION 'Test failed: joining again did not return the existing guest';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM vibetype.guest g
    JOIN vibetype.contact c ON c.id = g.contact_id
    WHERE g.id = _guest_id
      AND g.event_id = _event_id
      AND g.feedback = 'accepted'
      AND c.account_id = _account_id
      AND c.created_by = _account_id
  ) THEN
    RAISE EXCEPTION 'Test failed: the account did not join with its own contact as an accepted guest';
  END IF;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.guest_test('the joined guest is visible to the organizer', _organizer_id, ARRAY[_guest_id]);
END $$;
ROLLBACK TO SAVEPOINT event_invitation_link_redeem_account;

-- Without an account, the email address and first name become a new contact of the organizer.
SAVEPOINT event_invitation_link_redeem_anonymous;
DO $$
DECLARE
  _event_id UUID;
  _guest_id UUID;
  _guest_other_id UUID;
  _link_id UUID;
  _organizer_id UUID;
BEGIN
  _organizer_id := vibetype_test.account_registration_verified('organizer', 'organizer@example.com');
  _event_id := vibetype_test.event_create(_organizer_id, 'Event', 'event', '2099-01-01 20:00', 'private');

  PERFORM vibetype_test.invoker_set(_organizer_id);
  INSERT INTO vibetype.event_invitation_link (event_id) VALUES (_event_id) RETURNING id INTO _link_id;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set_anonymous();

  BEGIN
    PERFORM vibetype.event_invitation_link_redeem(_link_id);
    RAISE EXCEPTION 'Test failed: an anonymous visitor joined without an email address';
  EXCEPTION WHEN SQLSTATE 'VTIDM' THEN
    NULL;
  END;

  _guest_id := vibetype.event_invitation_link_redeem(_link_id, 'guest@example.com', 'Guest');
  _guest_other_id := vibetype.event_invitation_link_redeem(_link_id, 'guest@example.com', 'Impostor');
  PERFORM vibetype_test.invoker_set_previous();

  IF _guest_other_id = _guest_id THEN
    RAISE EXCEPTION 'Test failed: the same email address returned the existing guest';
  END IF;

  PERFORM vibetype_test.invoker_set(_organizer_id);
  IF NOT EXISTS (
    SELECT 1
    FROM vibetype.guest g
    JOIN vibetype.contact c ON c.id = g.contact_id
    WHERE g.id = _guest_id
      AND g.feedback = 'accepted'
      AND c.created_by = _organizer_id
      AND c.account_id IS NULL
      AND c.email_address = 'guest@example.com'
      AND c.first_name = 'Guest'
  ) THEN
    RAISE EXCEPTION 'Test failed: the anonymous visitor did not join with a new contact of the organizer';
  END IF;
  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT event_invitation_link_redeem_anonymous;

-- A deleted link, an ended event and a full event reject joining.
SAVEPOINT event_invitation_link_redeem_rejected;
DO $$
DECLARE
  _account_id UUID;
  _account_other_id UUID;
  _event_ended_id UUID;
  _event_full_id UUID;
  _link_deleted_id UUID;
  _link_ended_id UUID;
  _link_full_id UUID;
  _organizer_id UUID;
BEGIN
  _organizer_id := vibetype_test.account_registration_verified('organizer', 'organizer@example.com');
  _account_id := vibetype_test.account_registration_verified('guest', 'guest@example.com');
  _account_other_id := vibetype_test.account_registration_verified('other', 'other@example.com');
  _event_ended_id := vibetype_test.event_create(_organizer_id, 'Ended', 'ended', '2020-01-01 20:00', 'private');
  _event_full_id := vibetype_test.event_create(_organizer_id, 'Full', 'full', '2099-01-01 20:00', 'private');

  PERFORM vibetype_test.invoker_set(_organizer_id);
  UPDATE vibetype.event SET guest_count_maximum = 1 WHERE id = _event_full_id;
  INSERT INTO vibetype.event_invitation_link (event_id) VALUES (_event_ended_id) RETURNING id INTO _link_ended_id;
  INSERT INTO vibetype.event_invitation_link (event_id) VALUES (_event_full_id) RETURNING id INTO _link_full_id;
  _link_deleted_id := _link_full_id;
  DELETE FROM vibetype.event_invitation_link WHERE id = _link_deleted_id;
  INSERT INTO vibetype.event_invitation_link (event_id) VALUES (_event_full_id) RETURNING id INTO _link_full_id;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_account_id);

  BEGIN
    PERFORM vibetype.event_invitation_link_redeem(_link_deleted_id);
    RAISE EXCEPTION 'Test failed: a deleted link was redeemed';
  EXCEPTION WHEN SQLSTATE 'VTILN' THEN
    NULL;
  END;

  BEGIN
    PERFORM vibetype.event_invitation_link_redeem(_link_ended_id);
    RAISE EXCEPTION 'Test failed: an ended event was joined';
  EXCEPTION WHEN SQLSTATE 'VTEEN' THEN
    NULL;
  END;

  PERFORM vibetype.event_invitation_link_redeem(_link_full_id);
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_account_other_id);

  BEGIN
    PERFORM vibetype.event_invitation_link_redeem(_link_full_id);
    RAISE EXCEPTION 'Test failed: a full event was joined';
  EXCEPTION WHEN SQLSTATE 'VTGCM' THEN
    NULL;
  END;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT event_invitation_link_redeem_rejected;

ROLLBACK;
