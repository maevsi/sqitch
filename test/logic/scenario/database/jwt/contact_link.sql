\echo test_jwt_contact_link...

BEGIN;

-- Signing in links the contact behind a guest claim of the session to the account.
SAVEPOINT linked;
DO $$
DECLARE
  _account_id UUID;
  _contact_id UUID;
  _guest_id UUID;
  _organizer_id UUID;
BEGIN
  _organizer_id := vibetype_test.account_registration_verified('organizer', 'organizer@example.com');
  _contact_id := vibetype_test.contact_create(_organizer_id, 'guest@example.com');
  _guest_id := vibetype_test.guest_create(_organizer_id, vibetype_test.event_create(_organizer_id, 'Event', 'event', '2020-11-20 00:00', 'private'), _contact_id);
  _account_id := vibetype_test.account_registration_verified('guest', 'guest@example.com');

  PERFORM set_config('jwt.claims.guests', json_build_array(_guest_id)::TEXT, true);
  PERFORM set_config('jwt.claims.sub', '', true);

  IF vibetype.jwt_create('guest', 'password') IS NULL THEN
    RAISE EXCEPTION 'Test failed: the sign-in did not return a token';
  END IF;

  IF (SELECT account_id FROM vibetype.contact WHERE id = _contact_id) IS DISTINCT FROM _account_id THEN
    RAISE EXCEPTION 'Test failed: the sign-in did not link the contact of the guest claim';
  END IF;

  IF current_setting('jwt.claims.sub', true) <> '' THEN
    RAISE EXCEPTION 'Test failed: the sign-in did not restore the invoker';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT linked;

-- A failed sign-in links nothing.
SAVEPOINT password_incorrect;
DO $$
DECLARE
  _contact_id UUID;
  _guest_id UUID;
  _organizer_id UUID;
BEGIN
  _organizer_id := vibetype_test.account_registration_verified('organizer', 'organizer@example.com');
  _contact_id := vibetype_test.contact_create(_organizer_id, 'guest@example.com');
  _guest_id := vibetype_test.guest_create(_organizer_id, vibetype_test.event_create(_organizer_id, 'Event', 'event', '2020-11-20 00:00', 'private'), _contact_id);
  PERFORM vibetype_test.account_registration_verified('guest', 'guest@example.com');

  PERFORM set_config('jwt.claims.guests', json_build_array(_guest_id)::TEXT, true);
  PERFORM set_config('jwt.claims.sub', '', true);

  IF vibetype.jwt_create('guest', 'password_incorrect') IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: the sign-in with an incorrect password returned a token';
  END IF;

  IF (SELECT account_id FROM vibetype.contact WHERE id = _contact_id) IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: the failed sign-in linked the contact';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT password_incorrect;

-- A contact stays unlinked when its creator already has a contact for the account, or when the account blocks its creator, and of several contacts by the same creator only one is linked.
SAVEPOINT skipped;
DO $$
DECLARE
  _account_id UUID;
  _blocked_contact_id UUID;
  _blocked_guest_id UUID;
  _blocked_id UUID;
  _contact_existing_id UUID;
  _contact_first_id UUID;
  _contact_second_id UUID;
  _guest_existing_id UUID;
  _guest_first_id UUID;
  _guest_second_id UUID;
  _organizer_existing_id UUID;
  _organizer_id UUID;
BEGIN
  _organizer_id := vibetype_test.account_registration_verified('organizer', 'organizer@example.com');
  _contact_first_id := vibetype_test.contact_create(_organizer_id, 'guest@example.com');
  _contact_second_id := vibetype_test.contact_create(_organizer_id, 'guest.second@example.com');
  _guest_first_id := vibetype_test.guest_create(_organizer_id, vibetype_test.event_create(_organizer_id, 'Event', 'event', '2020-11-20 00:00', 'private'), _contact_first_id);
  _guest_second_id := vibetype_test.guest_create(_organizer_id, vibetype_test.event_create(_organizer_id, 'Event Second', 'event-second', '2020-11-20 00:00', 'private'), _contact_second_id);

  _blocked_id := vibetype_test.account_registration_verified('blocked', 'blocked@example.com');
  _blocked_contact_id := vibetype_test.contact_create(_blocked_id, 'guest@example.com');
  _blocked_guest_id := vibetype_test.guest_create(_blocked_id, vibetype_test.event_create(_blocked_id, 'Event', 'event', '2020-11-20 00:00', 'private'), _blocked_contact_id);

  _organizer_existing_id := vibetype_test.account_registration_verified('existing', 'existing@example.com');
  _contact_existing_id := vibetype_test.contact_create(_organizer_existing_id, 'guest@example.com');
  _guest_existing_id := vibetype_test.guest_create(_organizer_existing_id, vibetype_test.event_create(_organizer_existing_id, 'Event', 'event', '2020-11-20 00:00', 'private'), _contact_existing_id);

  _account_id := vibetype_test.account_registration_verified('guest', 'guest@example.com');
  PERFORM vibetype_test.contact_create(_organizer_existing_id, 'guest@example.com');
  PERFORM vibetype_test.account_block_create(_account_id, _blocked_id);

  PERFORM set_config('jwt.claims.guests', json_build_array(_blocked_guest_id, _guest_existing_id, _guest_first_id, _guest_second_id)::TEXT, true);
  PERFORM set_config('jwt.claims.sub', '', true);

  IF vibetype.jwt_create('guest', 'password') IS NULL THEN
    RAISE EXCEPTION 'Test failed: the sign-in did not return a token';
  END IF;

  IF (SELECT account_id FROM vibetype.contact WHERE id = _contact_first_id) IS DISTINCT FROM _account_id
    OR (SELECT account_id FROM vibetype.contact WHERE id = _contact_second_id) IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: the sign-in did not link exactly the first contact of the organizer';
  END IF;

  IF (SELECT account_id FROM vibetype.contact WHERE id = _contact_existing_id) IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: the sign-in linked a contact whose creator already has one for the account';
  END IF;

  IF (SELECT account_id FROM vibetype.contact WHERE id = _blocked_contact_id) IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: the sign-in linked a contact of a blocked account';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT skipped;

ROLLBACK;
