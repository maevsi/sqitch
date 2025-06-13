\echo test_event_favorite...

BEGIN;

SAVEPOINT event_favorite_account;
DO $$
DECLARE
  _account_favorite_owner UUID;
  _account_other UUID;
  _count INTEGER;
  _event UUID;
BEGIN
  _account_favorite_owner := vibetype_test.account_registration_verified('favorite-owner', 'email+a@example.com');
  _account_other := vibetype_test.account_registration_verified('other', 'email+b@example.com');
  _event := vibetype_test.event_create(_account_favorite_owner, 'Name', 'slug', '1970-01-01 00:00', 'public');

  INSERT INTO vibetype.event_favorite (event_id, created_by)
    VALUES (_event, _account_favorite_owner);

  PERFORM vibetype_test.invoker_set(_account_favorite_owner);
  SELECT COUNT(1) INTO _count FROM vibetype.event_favorite;

  IF _count <> 1 THEN
    RAISE EXCEPTION 'Exactly one event favorite should be returned for the account that has one.';
  END IF;

  PERFORM vibetype_test.invoker_set(_account_other);
  SELECT COUNT(1) INTO _count FROM vibetype.event_favorite;

  IF _count <> 0 THEN
    RAISE EXCEPTION 'No event favorites should be returned for an account that hasn''t set any.';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_favorite_account;


SAVEPOINT event_favorite_anonymous;
DO $$
DECLARE
  _account UUID;
  _event UUID;
BEGIN
  _account := vibetype_test.account_registration_verified('username', 'email@example.com');
  _event := vibetype_test.event_create(_account, 'Name', 'slug', '1970-01-01 00:00', 'public');

  INSERT INTO vibetype.event_favorite (event_id, created_by) VALUES (_event, _account);

  PERFORM vibetype_test.invoker_set_anonymous();

  IF (SELECT 1 FROM vibetype.event_favorite) IS NOT NULL THEN
    RAISE EXCEPTION 'No event favorites should be returned for anonymous users.';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_favorite_anonymous;

ROLLBACK;
