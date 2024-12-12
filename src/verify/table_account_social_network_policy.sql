BEGIN;

SAVEPOINT select_account;
DO $$
BEGIN
  SET LOCAL role TO maevsi_account;
  PERFORM * FROM maevsi.account_social_network;
END $$;
ROLLBACK TO SAVEPOINT select_account;

SAVEPOINT select_anonymous;
DO $$
BEGIN
  SET LOCAL role TO maevsi_anonymous;
  PERFORM * FROM maevsi.account_social_network;
END $$;
ROLLBACK TO SAVEPOINT select_anonymous;

SAVEPOINT insert_account;
DO $$
BEGIN
  INSERT INTO maevsi_private.account(id, email_address, password_hash) VALUES ('00000000-0000-0000-0000-000000000000', 'email@example.com', '$2a$06$xdJFoht/HQ/4798obSknNOc6hiBe60HXriyW/Oa3Ch7Oo3F.9WGLe');
  INSERT INTO maevsi.account(id, username) VALUES ('00000000-0000-0000-0000-000000000000', 'username');

  SET LOCAL role TO maevsi_account;
  SET LOCAL jwt.claims.account_id TO '00000000-0000-0000-0000-000000000000';
  INSERT INTO maevsi.account_social_network(account_id, social_network, social_network_username)
  VALUES ('00000000-0000-0000-0000-000000000000', 'instagram', 'username');
END $$;
ROLLBACK TO SAVEPOINT insert_account;

SAVEPOINT insert_anonymous;
DO $$
BEGIN
  INSERT INTO maevsi_private.account(id, email_address, password_hash) VALUES ('00000000-0000-0000-0000-000000000000', 'email@example.com', '$2a$06$xdJFoht/HQ/4798obSknNOc6hiBe60HXriyW/Oa3Ch7Oo3F.9WGLe');
  INSERT INTO maevsi.account(id, username) VALUES ('00000000-0000-0000-0000-000000000000', 'username');

  SET LOCAL role TO maevsi_anonymous;
  INSERT INTO maevsi.account_social_network(account_id, social_network, social_network_username)
  VALUES ('00000000-0000-0000-0000-000000000000', 'instagram', 'username');
  RAISE EXCEPTION 'Test insert_anonymous failed: Anonymous users should not be able to insert';
EXCEPTION WHEN others THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT insert_anonymous;

SAVEPOINT update_account;
DO $$
BEGIN
  INSERT INTO maevsi_private.account(id, email_address, password_hash) VALUES ('00000000-0000-0000-0000-000000000000', 'email@example.com', '$2a$06$xdJFoht/HQ/4798obSknNOc6hiBe60HXriyW/Oa3Ch7Oo3F.9WGLe');
  INSERT INTO maevsi.account(id, username) VALUES ('00000000-0000-0000-0000-000000000000', 'username');
  INSERT INTO maevsi.account_social_network(account_id, social_network, social_network_username) VALUES ('00000000-0000-0000-0000-000000000000', 'instagram', 'username');

  SET LOCAL role TO maevsi_account;
  UPDATE maevsi.account_social_network SET social_network_username = 'username-updated';
END $$;
ROLLBACK TO SAVEPOINT update_account;

SAVEPOINT insert_anonymous;
DO $$
BEGIN
  INSERT INTO maevsi_private.account(id, email_address, password_hash) VALUES ('00000000-0000-0000-0000-000000000000', 'email@example.com', '$2a$06$xdJFoht/HQ/4798obSknNOc6hiBe60HXriyW/Oa3Ch7Oo3F.9WGLe');
  INSERT INTO maevsi.account(id, username) VALUES ('00000000-0000-0000-0000-000000000000', 'username');
  INSERT INTO maevsi.account_social_network(account_id, social_network, social_network_username) VALUES ('00000000-0000-0000-0000-000000000000', 'instagram', 'username');

  SET LOCAL role TO maevsi_anonymous;
  UPDATE maevsi.account_social_network SET social_network_username = 'username-updated';
  RAISE EXCEPTION 'Test update_anonymous failed: Anonymous users should not be able to update';
EXCEPTION WHEN others THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT insert_anonymous;

SAVEPOINT delete_account;
DO $$
BEGIN
  INSERT INTO maevsi_private.account(id, email_address, password_hash) VALUES ('00000000-0000-0000-0000-000000000000', 'email@example.com', '$2a$06$xdJFoht/HQ/4798obSknNOc6hiBe60HXriyW/Oa3Ch7Oo3F.9WGLe');
  INSERT INTO maevsi.account(id, username) VALUES ('00000000-0000-0000-0000-000000000000', 'username');
  INSERT INTO maevsi.account_social_network(account_id, social_network, social_network_username) VALUES ('00000000-0000-0000-0000-000000000000', 'instagram', 'username');

  SET LOCAL role TO maevsi_account;
  DELETE FROM maevsi.account_social_network;
END $$;
ROLLBACK TO SAVEPOINT delete_account;

SAVEPOINT delete_anonymous;
DO $$
BEGIN
  INSERT INTO maevsi_private.account(id, email_address, password_hash) VALUES ('00000000-0000-0000-0000-000000000000', 'email@example.com', '$2a$06$xdJFoht/HQ/4798obSknNOc6hiBe60HXriyW/Oa3Ch7Oo3F.9WGLe');
  INSERT INTO maevsi.account(id, username) VALUES ('00000000-0000-0000-0000-000000000000', 'username');
  INSERT INTO maevsi.account_social_network(account_id, social_network, social_network_username) VALUES ('00000000-0000-0000-0000-000000000000', 'instagram', 'username');

  SET LOCAL role TO maevsi_anonymous;
  DELETE FROM maevsi.account_social_network;
  RAISE EXCEPTION 'Test delete_anonymous failed: Anonymous users should not be able to delete';
EXCEPTION WHEN others THEN
  NULL;
END $$;
ROLLBACK TO SAVEPOINT delete_anonymous;

ROLLBACK;
