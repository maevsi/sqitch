\echo test_account_notification...

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

BEGIN;

SET LOCAL role.vibetype_username TO :'role_service_vibetype_username';

SAVEPOINT event_invitation;
DO $$
DECLARE
  _a UUID;
  _b UUID;
  _contact_b UUID;
  _contact_email_only UUID;
  _contact_self UUID;
  _event UUID;
  _guest_b UUID;
  _guest_email_only UUID;
  _guest_self UUID;
  _notification vibetype.account_notification;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _b := vibetype_test.account_registration_verified('b', 'b@example.com');
  _contact_b := vibetype_test.contact_create(_a, 'b@example.com');
  _contact_email_only := vibetype_test.contact_create(_a, 'nobody@example.com');
  _contact_self := vibetype_test.contact_select_by_account_id(_a);
  _event := vibetype_test.event_create(_a, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  _guest_b := vibetype_test.guest_create(_a, _event, _contact_b);
  _guest_email_only := vibetype_test.guest_create(_a, _event, _contact_email_only);
  _guest_self := vibetype_test.guest_create(_a, _event, _contact_self);

  PERFORM vibetype_test.invoker_set(_a);
  PERFORM vibetype.invite(_guest_b, 'de');
  PERFORM vibetype.invite(_guest_email_only, 'de');
  PERFORM vibetype.invite(_guest_self, 'de');
  PERFORM vibetype_test.invoker_set_previous();

  _notification := vibetype_test.account_notification_get(_b, 'event_invitation');

  IF vibetype_test.account_notification_count(_b, 'event_invitation') != 1
    OR _notification.actor_account_id IS DISTINCT FROM _a
    OR _notification.event_id IS DISTINCT FROM _event
    OR _notification.guest_id IS DISTINCT FROM _guest_b
    OR _notification.read_at IS NOT NULL
    OR _notification.payload IS DISTINCT FROM jsonb_build_object(
      'actor_username', 'a',
      'event_creator_username', 'a',
      'event_name', 'Event by A',
      'event_slug', 'event-by-a',
      'event_start', (SELECT start FROM vibetype.event WHERE id = _event)
    )
  THEN
    RAISE EXCEPTION 'Test failed (event_invitation): unexpected notification %', _notification;
  END IF;

  IF vibetype_test.account_notification_count(_a) != 0 THEN
    RAISE EXCEPTION 'Test failed (event_invitation): the creator notified themselves';
  END IF;

  IF (SELECT count(*) FROM vibetype.account_notification) != 1 THEN
    RAISE EXCEPTION 'Test failed (event_invitation): invitations without a recipient account created notifications';
  END IF;

  -- collapse: an unread invitation is replaced
  PERFORM vibetype_test.invoker_set(_a);
  PERFORM vibetype.invite(_guest_b, 'de');
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.account_notification_count(_b, 'event_invitation') != 1
    OR (vibetype_test.account_notification_get(_b, 'event_invitation')).id = _notification.id
  THEN
    RAISE EXCEPTION 'Test failed (event_invitation): the unread invitation was not replaced';
  END IF;

  -- a read invitation stays
  PERFORM vibetype_test.account_notification_exec('UPDATE vibetype.account_notification SET read_at = CURRENT_TIMESTAMP');
  PERFORM vibetype_test.invoker_set(_a);
  PERFORM vibetype.invite(_guest_b, 'de');
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.account_notification_count(_b, 'event_invitation') != 2 THEN
    RAISE EXCEPTION 'Test failed (event_invitation): the read invitation was removed';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_invitation;

SAVEPOINT event_invitation_blocked;
DO $$
DECLARE
  _a UUID;
  _b UUID;
  _c UUID;
  _contact_b UUID;
  _contact_c UUID;
  _event UUID;
  _guest_b UUID;
  _guest_c UUID;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _b := vibetype_test.account_registration_verified('b', 'b@example.com');
  _c := vibetype_test.account_registration_verified('c', 'c@example.com');
  _contact_b := vibetype_test.contact_create(_a, 'b@example.com');
  _contact_c := vibetype_test.contact_create(_a, 'c@example.com');
  _event := vibetype_test.event_create(_a, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  _guest_b := vibetype_test.guest_create(_a, _event, _contact_b);
  _guest_c := vibetype_test.guest_create(_a, _event, _contact_c);

  PERFORM vibetype_test.account_block_create(_b, _a);
  PERFORM vibetype_test.account_block_create(_a, _c);

  PERFORM vibetype_test.invoker_set(_a);
  PERFORM vibetype.invite(_guest_b, 'de');
  PERFORM vibetype.invite(_guest_c, 'de');
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.account_notification_count(_b) != 0 OR vibetype_test.account_notification_count(_c) != 0 THEN
    RAISE EXCEPTION 'Test failed (event_invitation_blocked): blocked accounts were notified';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_invitation_blocked;

SAVEPOINT guest_feedback;
DO $$
DECLARE
  _a UUID;
  _b UUID;
  _contact_b UUID;
  _contact_email_only UUID;
  _event UUID;
  _guest_b UUID;
  _guest_email_only UUID;
  _notification vibetype.account_notification;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _b := vibetype_test.account_registration_verified('b', 'b@example.com');
  _contact_b := vibetype_test.contact_create(_a, 'b@example.com');
  _contact_email_only := vibetype_test.contact_create(_a, 'nobody@example.com');
  PERFORM vibetype_test.account_notification_exec(format('UPDATE vibetype.contact SET first_name = ''Nobody'', last_name = ''Known'' WHERE id = %L', _contact_email_only));
  _event := vibetype_test.event_create(_a, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  _guest_b := vibetype_test.guest_create(_a, _event, _contact_b);
  _guest_email_only := vibetype_test.guest_create(_a, _event, _contact_email_only);

  PERFORM vibetype_test.invoker_set(_b);
  UPDATE vibetype.guest SET feedback = 'accepted' WHERE id = _guest_b;
  PERFORM vibetype_test.invoker_set_previous();

  _notification := vibetype_test.account_notification_get(_a, 'guest_feedback');

  IF vibetype_test.account_notification_count(_a, 'guest_feedback') != 1
    OR _notification.actor_account_id IS DISTINCT FROM _b
    OR _notification.event_id IS DISTINCT FROM _event
    OR _notification.guest_id IS DISTINCT FROM _guest_b
    OR _notification.payload ->> 'feedback' IS DISTINCT FROM 'accepted'
    OR _notification.payload ->> 'guest_name' IS DISTINCT FROM 'b'
    OR _notification.payload ->> 'actor_username' IS DISTINCT FROM 'b'
    OR _notification.payload ->> 'event_creator_username' IS DISTINCT FROM 'a'
  THEN
    RAISE EXCEPTION 'Test failed (guest_feedback): unexpected notification %', _notification;
  END IF;

  IF vibetype_test.account_notification_count(_b) != 0 THEN
    RAISE EXCEPTION 'Test failed (guest_feedback): the guest notified themselves';
  END IF;

  -- collapse: the unread notification is replaced
  PERFORM vibetype_test.invoker_set(_b);
  UPDATE vibetype.guest SET feedback = 'canceled' WHERE id = _guest_b;
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.account_notification_count(_a, 'guest_feedback') != 1
    OR (vibetype_test.account_notification_get(_a, 'guest_feedback')).payload ->> 'feedback' IS DISTINCT FROM 'canceled'
  THEN
    RAISE EXCEPTION 'Test failed (guest_feedback): the unread notification was not replaced';
  END IF;

  -- unchanged feedback and paper feedback do not notify
  PERFORM vibetype_test.invoker_set(_b);
  UPDATE vibetype.guest SET feedback = 'canceled' WHERE id = _guest_b;
  PERFORM vibetype_test.invoker_set_previous();
  PERFORM vibetype_test.account_notification_exec('UPDATE vibetype.account_notification SET read_at = CURRENT_TIMESTAMP');

  PERFORM vibetype_test.invoker_set(_b);
  UPDATE vibetype.guest SET feedback = 'canceled' WHERE id = _guest_b;
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.account_notification_count(_a, 'guest_feedback') != 1 THEN
    RAISE EXCEPTION 'Test failed (guest_feedback): unchanged feedback notified';
  END IF;

  -- the creator answering for a guest does not notify themselves
  PERFORM vibetype_test.invoker_set(_a);
  UPDATE vibetype.guest SET feedback = 'accepted' WHERE id = _guest_email_only;
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.account_notification_count(_a) != 1 THEN
    RAISE EXCEPTION 'Test failed (guest_feedback): the creator notified themselves';
  END IF;

  -- anonymous feedback has no actor and names the contact
  PERFORM vibetype_test.account_notification_exec(format('UPDATE vibetype.guest SET feedback = ''canceled'' WHERE id = %L', _guest_email_only));
  SELECT * INTO _notification FROM vibetype.account_notification WHERE guest_id = _guest_email_only;

  IF _notification.guest_id IS DISTINCT FROM _guest_email_only
    OR _notification.actor_account_id IS NOT NULL
    OR _notification.payload ->> 'guest_name' IS DISTINCT FROM 'Nobody Known'
  THEN
    RAISE EXCEPTION 'Test failed (guest_feedback): unexpected anonymous notification %', _notification;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT guest_feedback;

SAVEPOINT guest_feedback_blocked;
DO $$
DECLARE
  _a UUID;
  _b UUID;
  _contact_b UUID;
  _event UUID;
  _guest_b UUID;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _b := vibetype_test.account_registration_verified('b', 'b@example.com');
  _contact_b := vibetype_test.contact_create(_a, 'b@example.com');
  _event := vibetype_test.event_create(_a, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  _guest_b := vibetype_test.guest_create(_a, _event, _contact_b);

  PERFORM vibetype_test.account_block_create(_a, _b);

  PERFORM vibetype_test.invoker_set(_b);
  UPDATE vibetype.guest SET feedback = 'accepted' WHERE id = _guest_b;
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.account_notification_count(_a) != 0 THEN
    RAISE EXCEPTION 'Test failed (guest_feedback_blocked): feedback of a blocked account notified';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT guest_feedback_blocked;

SAVEPOINT event_updated;
DO $$
DECLARE
  _a UUID;
  _b UUID;
  _c UUID;
  _contact_b UUID;
  _contact_c UUID;
  _d UUID;
  _event UUID;
  _notification vibetype.account_notification;
  _other_event UUID;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _b := vibetype_test.account_registration_verified('b', 'b@example.com');
  _c := vibetype_test.account_registration_verified('c', 'c@example.com');
  _d := vibetype_test.account_registration_verified('d', 'd@example.com');
  _event := vibetype_test.event_create(_a, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  _other_event := vibetype_test.event_create(_a, 'Other by A', 'other-by-a', '2025-07-01 20:00', 'public');
  _contact_b := vibetype_test.contact_create(_a, 'b@example.com');
  PERFORM vibetype_test.guest_create(_a, _event, _contact_b);
  _contact_c := vibetype_test.contact_create(_a, 'c@example.com');
  PERFORM vibetype_test.guest_create(_a, _event, _contact_c);
  PERFORM vibetype_test.guest_create(_a, _event, vibetype_test.contact_create(_a, 'd@example.com'));
  PERFORM vibetype_test.guest_create(_a, _event, vibetype_test.contact_select_by_account_id(_a));
  PERFORM vibetype_test.guest_create(_a, _other_event, _contact_b);

  PERFORM vibetype_test.account_notification_exec(format('UPDATE vibetype.guest SET feedback = ''canceled'' WHERE event_id = %L AND contact_id = %L', _event, _contact_c));
  PERFORM vibetype_test.account_block_create(_d, _a);

  -- fields that are not part of the notification
  PERFORM vibetype_test.invoker_set(_a);
  UPDATE vibetype.event SET name = 'Renamed', description = 'Description' WHERE id = _event;
  PERFORM vibetype_test.invoker_set_previous();

  IF (SELECT count(*) FROM vibetype.account_notification WHERE type = 'event_updated') != 0 THEN
    RAISE EXCEPTION 'Test failed (event_updated): unrelated changes notified';
  END IF;

  PERFORM vibetype_test.invoker_set(_a);
  UPDATE vibetype.event SET start = '2025-06-02 20:00' WHERE id = _event;
  PERFORM vibetype_test.invoker_set_previous();

  _notification := vibetype_test.account_notification_get(_b, 'event_updated');

  IF _notification.event_id IS DISTINCT FROM _event
    OR _notification.actor_account_id IS DISTINCT FROM _a
    OR _notification.payload -> 'changes' IS DISTINCT FROM '["start"]'::jsonb
    OR _notification.payload ->> 'event_name' IS DISTINCT FROM 'Renamed'
    OR _notification.payload ->> 'event_slug' IS DISTINCT FROM 'event-by-a'
  THEN
    RAISE EXCEPTION 'Test failed (event_updated): unexpected notification %', _notification;
  END IF;

  IF vibetype_test.account_notification_count(_a, 'event_updated') != 0
    OR vibetype_test.account_notification_count(_c, 'event_updated') != 0
    OR vibetype_test.account_notification_count(_d, 'event_updated') != 0
    OR (SELECT count(*) FROM vibetype.account_notification WHERE type = 'event_updated') != 1
  THEN
    RAISE EXCEPTION 'Test failed (event_updated): only the guest who did not cancel and did not block should be notified';
  END IF;

  -- collapse: unread notifications merge their changes
  PERFORM vibetype_test.invoker_set(_a);
  UPDATE vibetype.event SET "end" = '2025-06-02 22:00', is_remote = TRUE WHERE id = _event;
  PERFORM vibetype_test.invoker_set_previous();

  _notification := vibetype_test.account_notification_get(_b, 'event_updated');

  IF vibetype_test.account_notification_count(_b, 'event_updated') != 1
    OR _notification.payload -> 'changes' IS DISTINCT FROM '["attendance", "end", "start"]'::jsonb
  THEN
    RAISE EXCEPTION 'Test failed (event_updated): unexpected collapsed notification %', _notification;
  END IF;

  -- a read notification stays and starts a new one
  PERFORM vibetype_test.account_notification_exec('UPDATE vibetype.account_notification SET read_at = CURRENT_TIMESTAMP');
  PERFORM vibetype_test.invoker_set(_a);
  UPDATE vibetype.event SET address_id = NULL, start = '2025-06-03 20:00' WHERE id = _event;
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.account_notification_count(_b, 'event_updated') != 2
    OR (vibetype_test.account_notification_get(_b, 'event_updated')).payload -> 'changes' IS DISTINCT FROM '["start"]'::jsonb
  THEN
    RAISE EXCEPTION 'Test failed (event_updated): unexpected notifications after reading';
  END IF;

  -- one statement over several events
  PERFORM vibetype_test.account_notification_exec(format('UPDATE vibetype.event SET start = start + INTERVAL ''1 day'' WHERE created_by = %L', _a));

  IF vibetype_test.account_notification_count(_b, 'event_updated') != 3
    OR (SELECT count(*) FROM vibetype.account_notification WHERE account_id = _b AND event_id = _other_event) != 1
  THEN
    RAISE EXCEPTION 'Test failed (event_updated): unexpected notifications after a multi-row update';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_updated;

SAVEPOINT event_deleted;
DO $$
DECLARE
  _a UUID;
  _b UUID;
  _c UUID;
  _contact_b UUID;
  _contact_c UUID;
  _d UUID;
  _event UUID;
  _notification vibetype.account_notification;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _b := vibetype_test.account_registration_verified('b', 'b@example.com');
  _c := vibetype_test.account_registration_verified('c', 'c@example.com');
  _d := vibetype_test.account_registration_verified('d', 'd@example.com');
  _event := vibetype_test.event_create(_a, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  _contact_b := vibetype_test.contact_create(_a, 'b@example.com');
  _contact_c := vibetype_test.contact_create(_a, 'c@example.com');
  PERFORM vibetype_test.guest_create(_a, _event, _contact_b);
  PERFORM vibetype_test.guest_create(_a, _event, _contact_c);
  PERFORM vibetype_test.guest_create(_a, _event, vibetype_test.contact_create(_a, 'd@example.com'));
  PERFORM vibetype_test.guest_create(_a, _event, vibetype_test.contact_select_by_account_id(_a));

  PERFORM vibetype_test.account_notification_exec(format('UPDATE vibetype.guest SET feedback = ''canceled'' WHERE event_id = %L AND contact_id = %L', _event, _contact_c));
  PERFORM vibetype_test.account_block_create(_a, _d);

  PERFORM vibetype_test.invoker_set(_a);
  PERFORM vibetype.invite((SELECT id FROM vibetype.guest WHERE event_id = _event AND contact_id = _contact_b), 'de');
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.account_notification_count(_b, 'event_invitation') != 1 THEN
    RAISE EXCEPTION 'Test failed (event_deleted): the invitation is missing before the deletion';
  END IF;

  PERFORM vibetype_test.invoker_set(_a);
  DELETE FROM vibetype.event WHERE id = _event;
  PERFORM vibetype_test.invoker_set_previous();

  _notification := vibetype_test.account_notification_get(_b, 'event_deleted');

  IF _notification.event_id IS NOT NULL
    OR _notification.guest_id IS NOT NULL
    OR _notification.actor_account_id IS DISTINCT FROM _a
    OR _notification.payload ->> 'event_name' IS DISTINCT FROM 'Event by A'
    OR _notification.payload ->> 'event_slug' IS DISTINCT FROM 'event-by-a'
    OR _notification.payload ->> 'event_creator_username' IS DISTINCT FROM 'a'
  THEN
    RAISE EXCEPTION 'Test failed (event_deleted): unexpected notification %', _notification;
  END IF;

  IF (SELECT count(*) FROM vibetype.account_notification) != 1 THEN
    RAISE EXCEPTION 'Test failed (event_deleted): expected only the deletion notification, the others should be cascaded or skipped';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_deleted;

SAVEPOINT event_deleted_account_delete;
DO $$
DECLARE
  _a UUID;
  _b UUID;
  _event UUID;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _b := vibetype_test.account_registration_verified('b', 'b@example.com');
  _event := vibetype_test.event_create(_a, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  PERFORM vibetype_test.guest_create(_a, _event, vibetype_test.contact_create(_a, 'b@example.com'));

  PERFORM vibetype_test.invoker_set(_a);
  PERFORM vibetype.account_delete('password');
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.account_notification_count(_b) != 0 THEN
    RAISE EXCEPTION 'Test failed (event_deleted_account_delete): events cascading from an account deletion notified';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_deleted_account_delete;

SAVEPOINT friendship;
DO $$
DECLARE
  _a UUID;
  _b UUID;
  _c UUID;
  _d UUID;
  _friendship_ab UUID;
  _friendship_ca UUID;
  _notification vibetype.account_notification;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _b := vibetype_test.account_registration_verified('b', 'b@example.com');
  _c := vibetype_test.account_registration_verified('c', 'c@example.com');
  _d := vibetype_test.account_registration_verified('d', 'd@example.com');

  _friendship_ab := vibetype_test.friendship_request(_a, _b);
  _notification := vibetype_test.account_notification_get(_b, 'friendship_requested');

  IF vibetype_test.account_notification_count(_b, 'friendship_requested') != 1
    OR _notification.actor_account_id IS DISTINCT FROM _a
    OR _notification.friendship_id IS DISTINCT FROM _friendship_ab
    OR _notification.payload IS DISTINCT FROM jsonb_build_object('actor_username', 'a')
    OR vibetype_test.account_notification_count(_a) != 0
  THEN
    RAISE EXCEPTION 'Test failed (friendship): unexpected request notification %', _notification;
  END IF;

  PERFORM vibetype_test.friendship_accept(_b, _friendship_ab);
  _notification := vibetype_test.account_notification_get(_a, 'friendship_accepted');

  IF vibetype_test.account_notification_count(_a, 'friendship_accepted') != 1
    OR _notification.actor_account_id IS DISTINCT FROM _b
    OR _notification.friendship_id IS DISTINCT FROM _friendship_ab
    OR _notification.payload IS DISTINCT FROM jsonb_build_object('actor_username', 'b')
  THEN
    RAISE EXCEPTION 'Test failed (friendship): unexpected acceptance notification %', _notification;
  END IF;

  IF vibetype_test.account_notification_count(_b) != 0 THEN
    RAISE EXCEPTION 'Test failed (friendship): the request notification of the accepting account stayed';
  END IF;

  -- a declined request removes its notification
  _friendship_ca := vibetype_test.friendship_request(_c, _a);

  IF vibetype_test.account_notification_count(_a, 'friendship_requested') != 1 THEN
    RAISE EXCEPTION 'Test failed (friendship): the second request did not notify';
  END IF;

  PERFORM vibetype_test.friendship_reject(_a, _friendship_ca);

  IF vibetype_test.account_notification_count(_a, 'friendship_requested') != 0
    OR vibetype_test.account_notification_count(_c) != 0
  THEN
    RAISE EXCEPTION 'Test failed (friendship): a declined request left notifications';
  END IF;

  -- blocked accounts are skipped
  PERFORM vibetype_test.account_block_create(_d, _a);
  PERFORM vibetype_test.account_notification_exec(format(
    'INSERT INTO vibetype.friendship (a_account_id, b_account_id, created_by) VALUES (%L, %L, %L)',
    LEAST(_a, _d), GREATEST(_a, _d), _a
  ));

  IF vibetype_test.account_notification_count(_d) != 0 THEN
    RAISE EXCEPTION 'Test failed (friendship): a blocked account was notified';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT friendship;

SAVEPOINT friendship_accepted_blocked;
DO $$
DECLARE
  _a UUID;
  _b UUID;
  _friendship UUID;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _b := vibetype_test.account_registration_verified('b', 'b@example.com');
  _friendship := vibetype_test.friendship_request(_a, _b);

  PERFORM vibetype_test.account_block_create(_b, _a);
  PERFORM set_config('jwt.claims.sub', _b::TEXT, TRUE);
  PERFORM vibetype_test.account_notification_exec(format('UPDATE vibetype.friendship SET status = ''accepted'' WHERE id = %L', _friendship));
  PERFORM set_config('jwt.claims.sub', '', TRUE);

  IF vibetype_test.account_notification_count(_a) != 0 THEN
    RAISE EXCEPTION 'Test failed (friendship_accepted_blocked): a blocked account was notified';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT friendship_accepted_blocked;

SAVEPOINT account_notification_client;
DO $$
DECLARE
  _a UUID;
  _b UUID;
  _id UUID;
  _row_count INTEGER;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _b := vibetype_test.account_registration_verified('b', 'b@example.com');
  PERFORM vibetype_test.friendship_request(_a, _b);
  _id := (vibetype_test.account_notification_get(_b, 'friendship_requested')).id;

  -- recipient only
  PERFORM vibetype_test.invoker_set(_a);

  IF EXISTS (SELECT 1 FROM vibetype.account_notification) THEN
    RAISE EXCEPTION 'Test failed (account_notification_client): another account sees the notification';
  END IF;

  UPDATE vibetype.account_notification SET read_at = CURRENT_TIMESTAMP WHERE id = _id;
  GET DIAGNOSTICS _row_count = ROW_COUNT;
  IF _row_count != 0 THEN
    RAISE EXCEPTION 'Test failed (account_notification_client): another account updated the notification';
  END IF;

  DELETE FROM vibetype.account_notification WHERE id = _id;
  GET DIAGNOSTICS _row_count = ROW_COUNT;
  IF _row_count != 0 THEN
    RAISE EXCEPTION 'Test failed (account_notification_client): another account deleted the notification';
  END IF;

  PERFORM vibetype_test.invoker_set_previous();
  PERFORM vibetype_test.invoker_set(_b);

  IF (SELECT count(*) FROM vibetype.account_notification) != 1 THEN
    RAISE EXCEPTION 'Test failed (account_notification_client): the recipient does not see the notification';
  END IF;

  -- no inserts
  BEGIN
    INSERT INTO vibetype.account_notification (account_id, type) VALUES (_b, 'guest_feedback');
    RAISE EXCEPTION 'Test failed (account_notification_client): insert was allowed';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  -- no updates beyond read_at
  BEGIN
    UPDATE vibetype.account_notification SET payload = '{"a": 1}' WHERE id = _id;
    RAISE EXCEPTION 'Test failed (account_notification_client): payload update was allowed';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  BEGIN
    UPDATE vibetype.account_notification SET account_id = _a WHERE id = _id;
    RAISE EXCEPTION 'Test failed (account_notification_client): account_id update was allowed';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  UPDATE vibetype.account_notification SET read_at = CURRENT_TIMESTAMP WHERE id = _id;
  GET DIAGNOSTICS _row_count = ROW_COUNT;
  IF _row_count != 1 THEN
    RAISE EXCEPTION 'Test failed (account_notification_client): read_at update was not allowed';
  END IF;

  -- notifications of a blocked actor are hidden
  PERFORM vibetype_test.invoker_set_previous();
  PERFORM vibetype_test.account_block_create(_b, _a);
  PERFORM vibetype_test.invoker_set(_b);

  IF EXISTS (SELECT 1 FROM vibetype.account_notification) THEN
    RAISE EXCEPTION 'Test failed (account_notification_client): the notification of a blocked actor is visible';
  END IF;
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.account_notification_count(_b) != 1 THEN
    RAISE EXCEPTION 'Test failed (account_notification_client): the notification of a blocked actor was removed';
  END IF;

  PERFORM vibetype_test.account_block_delete(_b, _a);
  PERFORM vibetype_test.invoker_set(_b);

  -- delete
  DELETE FROM vibetype.account_notification WHERE id = _id;
  GET DIAGNOSTICS _row_count = ROW_COUNT;
  IF _row_count != 1 THEN
    RAISE EXCEPTION 'Test failed (account_notification_client): the recipient could not delete the notification';
  END IF;
  PERFORM vibetype_test.invoker_set_previous();

  -- anonymous
  PERFORM vibetype_test.invoker_set_anonymous();
  BEGIN
    PERFORM 1 FROM vibetype.account_notification;
    RAISE EXCEPTION 'Test failed (account_notification_client): anonymous select was allowed';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT account_notification_client;

SAVEPOINT preference_notification;
DO $$
DECLARE
  _a UUID;
  _b UUID;
  _id UUID;
  _row_count INTEGER;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _b := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.invoker_set(_a);
  INSERT INTO vibetype.preference_notification (account_id, type, is_push_enabled)
    VALUES (_a, 'guest_feedback', FALSE)
    RETURNING id INTO _id;

  BEGIN
    INSERT INTO vibetype.preference_notification (account_id, type, is_push_enabled) VALUES (_a, 'guest_feedback', TRUE);
    RAISE EXCEPTION 'Test failed (preference_notification): duplicate preference was allowed';
  EXCEPTION WHEN unique_violation THEN
    NULL;
  END;

  BEGIN
    INSERT INTO vibetype.preference_notification (account_id, type, is_push_enabled) VALUES (_b, 'event_updated', TRUE);
    RAISE EXCEPTION 'Test failed (preference_notification): preference for another account was allowed';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  UPDATE vibetype.preference_notification SET is_push_enabled = TRUE WHERE id = _id;
  GET DIAGNOSTICS _row_count = ROW_COUNT;
  IF _row_count != 1 THEN
    RAISE EXCEPTION 'Test failed (preference_notification): own preference was not updated';
  END IF;

  BEGIN
    UPDATE vibetype.preference_notification SET type = 'event_updated' WHERE id = _id;
    RAISE EXCEPTION 'Test failed (preference_notification): type update was allowed';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_b);

  IF EXISTS (SELECT 1 FROM vibetype.preference_notification) THEN
    RAISE EXCEPTION 'Test failed (preference_notification): another account sees the preference';
  END IF;

  UPDATE vibetype.preference_notification SET is_push_enabled = FALSE WHERE id = _id;
  GET DIAGNOSTICS _row_count = ROW_COUNT;
  IF _row_count != 0 THEN
    RAISE EXCEPTION 'Test failed (preference_notification): another account updated the preference';
  END IF;

  DELETE FROM vibetype.preference_notification WHERE id = _id;
  GET DIAGNOSTICS _row_count = ROW_COUNT;
  IF _row_count != 0 THEN
    RAISE EXCEPTION 'Test failed (preference_notification): another account deleted the preference';
  END IF;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_a);
  DELETE FROM vibetype.preference_notification WHERE id = _id;
  GET DIAGNOSTICS _row_count = ROW_COUNT;
  IF _row_count != 1 THEN
    RAISE EXCEPTION 'Test failed (preference_notification): own preference was not deleted';
  END IF;
  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT preference_notification;

SAVEPOINT account_notification_outbox;
DO $$
DECLARE
  _a UUID;
  _b UUID;
  _id UUID;
  _payload JSONB;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _b := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.outbox_capture();
  PERFORM vibetype_test.friendship_request(_a, _b);
  _id := (vibetype_test.account_notification_get(_b, 'friendship_requested')).id;

  _payload := vibetype_test.outbox_payload('account_notification.created', _id);

  IF _payload ->> 'aggregate_type' IS DISTINCT FROM 'account_notification'
    OR _payload -> 'data' IS DISTINCT FROM '{}'::jsonb
    OR (_payload ->> 'version')::INTEGER IS DISTINCT FROM 1
  THEN
    RAISE EXCEPTION 'Test failed (account_notification_outbox): unexpected outbox event %', _payload;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT account_notification_outbox;

SAVEPOINT account_notification_resolve;
DO $$
DECLARE
  _a UUID;
  _b UUID;
  _id UUID;
  _resolved RECORD;
BEGIN
  _a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _b := vibetype_test.account_registration_verified('b', 'b@example.com');
  PERFORM vibetype_test.friendship_request(_a, _b);
  _id := (vibetype_test.account_notification_get(_b, 'friendship_requested')).id;

  -- without devices, preference and language
  EXECUTE format('SET LOCAL ROLE %I', current_setting('role.vibetype_username'));
  SELECT * INTO _resolved FROM vibetype_private.outbox_account_notification_resolve(_id);

  IF _resolved.account_id IS DISTINCT FROM _b
    OR _resolved.type IS DISTINCT FROM 'friendship_requested'
    OR _resolved.payload IS DISTINCT FROM jsonb_build_object('actor_username', 'a')
    OR _resolved.friendship_id IS NULL
    OR _resolved.guest_id IS NOT NULL
    OR _resolved.event_id IS NOT NULL
    OR _resolved.is_push_enabled IS NOT TRUE
    OR _resolved.fcm_tokens IS DISTINCT FROM ARRAY[]::TEXT[]
  THEN
    RAISE EXCEPTION 'Test failed (account_notification_resolve): unexpected defaults %', _resolved;
  END IF;
  SET LOCAL ROLE NONE;

  -- with devices, preference and language
  PERFORM vibetype_test.account_notification_exec(format('INSERT INTO vibetype.device (created_by, fcm_token) VALUES (%1$L, ''token-1''), (%1$L, ''token-2''), (%2$L, ''token-a'')', _b, _a));
  PERFORM vibetype_test.account_notification_exec(format('INSERT INTO vibetype.preference_notification (account_id, type, is_push_enabled) VALUES (%L, ''friendship_requested'', FALSE)', _b));
  PERFORM vibetype_test.account_notification_exec(format('UPDATE vibetype.contact SET language = ''de'' WHERE account_id = %1$L AND created_by = %1$L', _b));

  EXECUTE format('SET LOCAL ROLE %I', current_setting('role.vibetype_username'));
  SELECT * INTO _resolved FROM vibetype_private.outbox_account_notification_resolve(_id);

  IF _resolved.is_push_enabled IS NOT FALSE
    OR _resolved.language IS DISTINCT FROM 'de'
    OR (SELECT array_agg(t ORDER BY t) FROM unnest(_resolved.fcm_tokens) t) IS DISTINCT FROM ARRAY['token-1', 'token-2']
  THEN
    RAISE EXCEPTION 'Test failed (account_notification_resolve): unexpected data %', _resolved;
  END IF;

  IF EXISTS (SELECT 1 FROM vibetype_private.outbox_account_notification_resolve(gen_random_uuid())) THEN
    RAISE EXCEPTION 'Test failed (account_notification_resolve): resolved a missing notification';
  END IF;

  -- the service role reads notifications and prunes tokens
  IF (SELECT count(*) FROM vibetype.account_notification) != 1 THEN
    RAISE EXCEPTION 'Test failed (account_notification_resolve): the service role cannot read notifications';
  END IF;

  DELETE FROM vibetype.device WHERE fcm_token = 'token-1';

  IF (SELECT count(*) FROM vibetype.device) != 2 THEN
    RAISE EXCEPTION 'Test failed (account_notification_resolve): the service role could not prune a token';
  END IF;
  SET LOCAL ROLE NONE;

  -- clients cannot resolve
  PERFORM vibetype_test.invoker_set(_b);
  BEGIN
    PERFORM vibetype_private.outbox_account_notification_resolve(_id);
    RAISE EXCEPTION 'Test failed (account_notification_resolve): an account resolved a notification';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set_anonymous();
  BEGIN
    PERFORM vibetype_private.outbox_account_notification_resolve(_id);
    RAISE EXCEPTION 'Test failed (account_notification_resolve): an anonymous user resolved a notification';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
  PERFORM vibetype_test.invoker_set_previous();

  -- a deleted notification resolves to nothing
  PERFORM vibetype_test.account_notification_exec(format('DELETE FROM vibetype.account_notification WHERE id = %L', _id));
  EXECUTE format('SET LOCAL ROLE %I', current_setting('role.vibetype_username'));

  IF EXISTS (SELECT 1 FROM vibetype_private.outbox_account_notification_resolve(_id)) THEN
    RAISE EXCEPTION 'Test failed (account_notification_resolve): resolved a deleted notification';
  END IF;
  SET LOCAL ROLE NONE;
END $$;
ROLLBACK TO SAVEPOINT account_notification_resolve;

ROLLBACK;
