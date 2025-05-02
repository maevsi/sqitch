BEGIN;

SAVEPOINT select_account;
DO $$
BEGIN
  SET LOCAL role TO vibetype_account;
  PERFORM * FROM vibetype.account_social_network;
END $$;
ROLLBACK TO SAVEPOINT select_account;

SAVEPOINT select_anonymous;
DO $$
BEGIN
  SET LOCAL role TO vibetype_anonymous;
  PERFORM * FROM vibetype.account_social_network;
END $$;
ROLLBACK TO SAVEPOINT select_anonymous;

SAVEPOINT insert_account;
DO $$
DECLARE
  _account_id UUID;
BEGIN
  _account_id := vibetype_test.account_registration_verified('username', 'email@example.com');

  PERFORM vibetype_test.invoker_set(_account_id);

  INSERT INTO vibetype.account_social_network(account_id, social_network, social_network_username)
  VALUES (_account_id, 'instagram', 'username');

END $$;
ROLLBACK TO SAVEPOINT insert_account;

SAVEPOINT insert_anonymous;
DO $$
DECLARE
  _account_id UUID;
BEGIN
  _account_id := vibetype_test.account_registration_verified('username', 'email@example.com');

  PERFORM vibetype_test.invoker_set_anonymous();

  INSERT INTO vibetype.account_social_network(account_id, social_network, social_network_username)
  VALUES (_account_id, 'instagram', 'username');

  RAISE EXCEPTION 'Test insert_anonymous failed: Anonymous users should not be able to insert';

EXCEPTION WHEN others THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT insert_anonymous;

SAVEPOINT update_account;
DO $$
DECLARE
  _account_id UUID;
BEGIN
  _account_id := vibetype_test.account_registration_verified('username', 'email@example.com');

  PERFORM vibetype_test.invoker_set(_account_id);

  INSERT INTO vibetype.account_social_network(account_id, social_network, social_network_username)
  VALUES (_account_id, 'instagram', 'username');

  UPDATE vibetype.account_social_network SET social_network_username = 'username-updated';

END $$;
ROLLBACK TO SAVEPOINT update_account;

SAVEPOINT update_anonymous;
DO $$
DECLARE
  _account_id UUID;
BEGIN
  _account_id := vibetype_test.account_registration_verified('username', 'email@example.com');

  PERFORM vibetype_test.invoker_set(_account_id);

  INSERT INTO vibetype.account_social_network(account_id, social_network, social_network_username)
  VALUES (_account_id, 'instagram', 'username');

  PERFORM vibetype_test.invoker_set_anonymous();

  UPDATE vibetype.account_social_network SET social_network_username = 'username-updated';

  RAISE EXCEPTION 'Test update_anonymous failed: Anonymous users should not be able to update';

EXCEPTION WHEN others THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT update_anonymous;

SAVEPOINT delete_account;
DO $$
DECLARE
  _account_id UUID;
BEGIN
  _account_id := vibetype_test.account_registration_verified('username', 'email@example.com');

  PERFORM vibetype_test.invoker_set(_account_id);

  INSERT INTO vibetype.account_social_network(account_id, social_network, social_network_username)
  VALUES (_account_id, 'instagram', 'username');

  PERFORM vibetype_test.invoker_set(_account_id);

  DELETE FROM vibetype.account_social_network;

END $$;
ROLLBACK TO SAVEPOINT delete_account;

SAVEPOINT delete_anonymous;
DO $$
DECLARE
  _account_id UUID;
BEGIN
  _account_id := vibetype_test.account_registration_verified('username', 'email@example.com');

  PERFORM vibetype_test.invoker_set(_account_id);

  INSERT INTO vibetype.account_social_network(account_id, social_network, social_network_username)
  VALUES (_account_id, 'instagram', 'username');

  PERFORM vibetype_test.invoker_set_anonymous();

  DELETE FROM vibetype.account_social_network;

  RAISE EXCEPTION 'Test delete_anonymous failed: Anonymous users should not be able to delete';

EXCEPTION WHEN others THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT delete_anonymous;

ROLLBACK;
