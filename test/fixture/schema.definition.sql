--
-- PostgreSQL database dump
--


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: sqitch; Type: SCHEMA; Schema: -; Owner: ci
--

CREATE SCHEMA sqitch;


ALTER SCHEMA sqitch OWNER TO ci;

--
-- Name: SCHEMA sqitch; Type: COMMENT; Schema: -; Owner: ci
--

COMMENT ON SCHEMA sqitch IS 'Sqitch database deployment metadata v1.1.';


--
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: ci
--

CREATE SCHEMA tiger;


ALTER SCHEMA tiger OWNER TO ci;

--
-- Name: tiger_data; Type: SCHEMA; Schema: -; Owner: ci
--

CREATE SCHEMA tiger_data;


ALTER SCHEMA tiger_data OWNER TO ci;

--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: ci
--

CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO ci;

--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: ci
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: vibetype; Type: SCHEMA; Schema: -; Owner: ci
--

CREATE SCHEMA vibetype;


ALTER SCHEMA vibetype OWNER TO ci;

--
-- Name: SCHEMA vibetype; Type: COMMENT; Schema: -; Owner: ci
--

COMMENT ON SCHEMA vibetype IS 'Is used by PostGraphile.';


--
-- Name: vibetype_private; Type: SCHEMA; Schema: -; Owner: ci
--

CREATE SCHEMA vibetype_private;


ALTER SCHEMA vibetype_private OWNER TO ci;

--
-- Name: SCHEMA vibetype_private; Type: COMMENT; Schema: -; Owner: ci
--

COMMENT ON SCHEMA vibetype_private IS 'Contains account information and is not used by PostGraphile.';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'Provides support for similarity of text using trigram matching, also used for speeding up LIKE queries.';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'Provides password hashing functions.';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


--
-- Name: achievement_type; Type: TYPE; Schema: vibetype; Owner: ci
--

CREATE TYPE vibetype.achievement_type AS ENUM (
    'early_bird',
    'meet_the_team'
);


ALTER TYPE vibetype.achievement_type OWNER TO ci;

--
-- Name: TYPE achievement_type; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TYPE vibetype.achievement_type IS 'Achievements that can be unlocked by users.';


--
-- Name: event_size; Type: TYPE; Schema: vibetype; Owner: ci
--

CREATE TYPE vibetype.event_size AS ENUM (
    'small',
    'medium',
    'large',
    'huge'
);


ALTER TYPE vibetype.event_size OWNER TO ci;

--
-- Name: TYPE event_size; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TYPE vibetype.event_size IS 'Possible event sizes: small, medium, large, huge.';


--
-- Name: jwt; Type: TYPE; Schema: vibetype; Owner: ci
--

CREATE TYPE vibetype.jwt AS (
	id uuid,
	account_id uuid,
	account_username text,
	exp bigint,
	guests uuid[],
	role text
);


ALTER TYPE vibetype.jwt OWNER TO ci;

--
-- Name: event_unlock_response; Type: TYPE; Schema: vibetype; Owner: ci
--

CREATE TYPE vibetype.event_unlock_response AS (
	creator_username text,
	event_slug text,
	jwt vibetype.jwt
);


ALTER TYPE vibetype.event_unlock_response OWNER TO ci;

--
-- Name: event_visibility; Type: TYPE; Schema: vibetype; Owner: ci
--

CREATE TYPE vibetype.event_visibility AS ENUM (
    'public',
    'private',
    'unlisted'
);


ALTER TYPE vibetype.event_visibility OWNER TO ci;

--
-- Name: TYPE event_visibility; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TYPE vibetype.event_visibility IS 'Possible visibilities of events and event groups: public, private and unlisted.';


--
-- Name: friendship_status; Type: TYPE; Schema: vibetype; Owner: ci
--

CREATE TYPE vibetype.friendship_status AS ENUM (
    'accepted',
    'requested'
);


ALTER TYPE vibetype.friendship_status OWNER TO ci;

--
-- Name: TYPE friendship_status; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TYPE vibetype.friendship_status IS 'Possible status values of a friend relation.
There is no status `rejected` because friendship records will be deleted when a friendship request is rejected.';


--
-- Name: invitation_feedback; Type: TYPE; Schema: vibetype; Owner: ci
--

CREATE TYPE vibetype.invitation_feedback AS ENUM (
    'accepted',
    'canceled'
);


ALTER TYPE vibetype.invitation_feedback OWNER TO ci;

--
-- Name: TYPE invitation_feedback; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TYPE vibetype.invitation_feedback IS 'Possible answers to an invitation: accepted, canceled.';


--
-- Name: invitation_feedback_paper; Type: TYPE; Schema: vibetype; Owner: ci
--

CREATE TYPE vibetype.invitation_feedback_paper AS ENUM (
    'none',
    'paper',
    'digital'
);


ALTER TYPE vibetype.invitation_feedback_paper OWNER TO ci;

--
-- Name: TYPE invitation_feedback_paper; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TYPE vibetype.invitation_feedback_paper IS 'Possible choices on how to receive a paper invitation: none, paper, digital.';


--
-- Name: language; Type: TYPE; Schema: vibetype; Owner: ci
--

CREATE TYPE vibetype.language AS ENUM (
    'de',
    'en'
);


ALTER TYPE vibetype.language OWNER TO ci;

--
-- Name: TYPE language; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TYPE vibetype.language IS 'Supported ISO 639 language codes.';


--
-- Name: social_network; Type: TYPE; Schema: vibetype; Owner: ci
--

CREATE TYPE vibetype.social_network AS ENUM (
    'facebook',
    'instagram',
    'tiktok',
    'x'
);


ALTER TYPE vibetype.social_network OWNER TO ci;

--
-- Name: TYPE social_network; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TYPE vibetype.social_network IS 'Social networks.';


--
-- Name: account_delete(text); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.account_delete(password text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _current_account_id UUID;
BEGIN
  _current_account_id := current_setting('jwt.claims.account_id')::UUID;

  IF (EXISTS (SELECT 1 FROM vibetype_private.account WHERE account.id = _current_account_id AND account.password_hash = public.crypt(account_delete.password, account.password_hash))) THEN
    IF (EXISTS (SELECT 1 FROM vibetype.event WHERE event.created_by = _current_account_id)) THEN
      RAISE 'You still own events!' USING ERRCODE = 'foreign_key_violation';
    ELSE
      DELETE FROM vibetype_private.account WHERE account.id = _current_account_id;
    END IF;
  ELSE
    RAISE 'Account with given password not found!' USING ERRCODE = 'invalid_password';
  END IF;
END;
$$;


ALTER FUNCTION vibetype.account_delete(password text) OWNER TO ci;

--
-- Name: FUNCTION account_delete(password text); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.account_delete(password text) IS 'Allows to delete an account.\n\nError codes:\n- **23503** when the account still has events.\n- **28P01** when the password is invalid.';


--
-- Name: account_email_address_verification(uuid); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.account_email_address_verification(code uuid) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _account vibetype_private.account;
BEGIN
  SELECT *
    FROM vibetype_private.account
    INTO _account
    WHERE account.email_address_verification = account_email_address_verification.code;

  IF (_account IS NULL) THEN
    RAISE 'Unknown verification code!' USING ERRCODE = 'no_data_found';
  END IF;

  IF (_account.email_address_verification_valid_until < CURRENT_TIMESTAMP) THEN
    RAISE 'Verification code expired!' USING ERRCODE = 'object_not_in_prerequisite_state';
  END IF;

  UPDATE vibetype_private.account
    SET email_address_verification = NULL
    WHERE email_address_verification = account_email_address_verification.code;
END;
$$;


ALTER FUNCTION vibetype.account_email_address_verification(code uuid) OWNER TO ci;

--
-- Name: FUNCTION account_email_address_verification(code uuid); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.account_email_address_verification(code uuid) IS 'Sets the account''s email address verification code to `NULL` for which the email address verification code equals the one passed and is up to date.\n\nError codes:\n- **P0002** when the verification code is unknown.\n- **55000** when the verification code has expired.';


--
-- Name: account_location_update(double precision, double precision); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.account_location_update(latitude double precision, longitude double precision) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
BEGIN
  UPDATE vibetype_private.account
    SET location = ST_Point(account_location_update.longitude, account_location_update.latitude, 4326)
    WHERE id = vibetype.invoker_account_id();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Account not found'
      USING ERRCODE = 'P0002'; -- no_data_found
  END IF;
END;
$$;


ALTER FUNCTION vibetype.account_location_update(latitude double precision, longitude double precision) OWNER TO ci;

--
-- Name: FUNCTION account_location_update(latitude double precision, longitude double precision); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.account_location_update(latitude double precision, longitude double precision) IS '@name update_account_location
Sets the location for the invoker''s account.

Error codes:
- **P0002** when the account is not found.';


--
-- Name: account_password_change(text, text); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.account_password_change(password_current text, password_new text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _current_account_id UUID;
BEGIN
  IF (char_length(account_password_change.password_new) < 8) THEN
      RAISE 'New password too short!' USING ERRCODE = 'invalid_parameter_value';
  END IF;

  _current_account_id := current_setting('jwt.claims.account_id')::UUID;

  IF (EXISTS (SELECT 1 FROM vibetype_private.account WHERE account.id = _current_account_id AND account.password_hash = public.crypt(account_password_change.password_current, account.password_hash))) THEN
    UPDATE vibetype_private.account SET password_hash = public.crypt(account_password_change.password_new, public.gen_salt('bf')) WHERE account.id = _current_account_id;
  ELSE
    RAISE 'Account with given password not found!' USING ERRCODE = 'invalid_password';
  END IF;
END;
$$;


ALTER FUNCTION vibetype.account_password_change(password_current text, password_new text) OWNER TO ci;

--
-- Name: FUNCTION account_password_change(password_current text, password_new text); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.account_password_change(password_current text, password_new text) IS 'Allows to change an account''s password.\n\nError codes:\n- **22023** when the new password is too short.\n- **28P01** when an account with the given password is not found.';


--
-- Name: account_password_reset(uuid, text); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.account_password_reset(code uuid, password text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _account vibetype_private.account;
BEGIN
  IF (char_length(account_password_reset.password) < 8) THEN
    RAISE 'Password too short!' USING ERRCODE = 'invalid_parameter_value';
  END IF;

  SELECT *
    FROM vibetype_private.account
    INTO _account
    WHERE account.password_reset_verification = account_password_reset.code;

  IF (_account IS NULL) THEN
    RAISE 'Unknown reset code!' USING ERRCODE = 'no_data_found';
  END IF;

  IF (_account.password_reset_verification_valid_until < CURRENT_TIMESTAMP) THEN
    RAISE 'Reset code expired!' USING ERRCODE = 'object_not_in_prerequisite_state';
  END IF;

  UPDATE vibetype_private.account
    SET
      password_hash = public.crypt(account_password_reset.password, public.gen_salt('bf')),
      password_reset_verification = NULL
    WHERE account.password_reset_verification = account_password_reset.code;
END;
$$;


ALTER FUNCTION vibetype.account_password_reset(code uuid, password text) OWNER TO ci;

--
-- Name: FUNCTION account_password_reset(code uuid, password text); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.account_password_reset(code uuid, password text) IS 'Sets a new password for an account if there was a request to do so before that''s still up to date.\n\nError codes:\n- **22023** when the password is too short.\n- **P0002** when the reset code is unknown.\n- **55000** when the reset code has expired.
';


--
-- Name: account_password_reset_request(text, text); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.account_password_reset_request(email_address text, language text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _notify_data RECORD;
BEGIN
  WITH updated AS (
    UPDATE vibetype_private.account
      SET password_reset_verification = gen_random_uuid()
      WHERE account.email_address = account_password_reset_request.email_address
      RETURNING *
  ) SELECT
    account.username,
    updated.email_address,
    updated.password_reset_verification,
    updated.password_reset_verification_valid_until
    INTO _notify_data
    FROM updated, vibetype.account
    WHERE updated.id = account.id;

  IF (_notify_data IS NULL) THEN
    -- noop
  ELSE
    INSERT INTO vibetype_private.notification (channel, payload) VALUES (
      'account_password_reset_request',
      jsonb_pretty(jsonb_build_object(
        'account', _notify_data,
        'template', jsonb_build_object('language', account_password_reset_request.language)
      ))
    );
  END IF;
END;
$$;


ALTER FUNCTION vibetype.account_password_reset_request(email_address text, language text) OWNER TO ci;

--
-- Name: FUNCTION account_password_reset_request(email_address text, language text); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.account_password_reset_request(email_address text, language text) IS 'Sets a new password reset verification code for an account.';


--
-- Name: account_registration(date, text, text, uuid, text, text); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.account_registration(birth_date date, email_address text, language text, legal_term_id uuid, password text, username text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _new_account_private vibetype_private.account;
  _new_account_public vibetype.account;
  _new_account_notify RECORD;
BEGIN
  IF account_registration.birth_date > CURRENT_DATE - INTERVAL '18 years' THEN
    RAISE EXCEPTION 'The birth date must be at least 18 years in the past'
      USING ERRCODE = 'VTBDA';
  END IF;

  IF (char_length(account_registration.password) < 8) THEN
    RAISE 'Password too short!' USING ERRCODE = 'VTPLL';
  END IF;

  IF (EXISTS (SELECT 1 FROM vibetype.account WHERE account.username = account_registration.username)) THEN
    RAISE 'An account with this username already exists!' USING ERRCODE = 'VTAUV';
  END IF;

  IF (EXISTS (SELECT 1 FROM vibetype_private.account WHERE account.email_address = account_registration.email_address)) THEN
    RETURN; -- silent fail as we cannot return meta information about users' email addresses
  END IF;

  INSERT INTO vibetype_private.account(birth_date, email_address, password_hash, last_activity) VALUES
    (account_registration.birth_date, account_registration.email_address, public.crypt(account_registration.password, public.gen_salt('bf')), CURRENT_TIMESTAMP)
    RETURNING * INTO _new_account_private;

  INSERT INTO vibetype.account(id, username) VALUES
    (_new_account_private.id, account_registration.username)
    RETURNING * INTO _new_account_public;

  SELECT
    _new_account_public.username,
    _new_account_private.email_address,
    _new_account_private.email_address_verification,
    _new_account_private.email_address_verification_valid_until
  INTO _new_account_notify;

  INSERT INTO vibetype.legal_term_acceptance(account_id, legal_term_id) VALUES
    (_new_account_private.id, account_registration.legal_term_id);

  INSERT INTO vibetype.contact(account_id, created_by) VALUES (_new_account_private.id, _new_account_private.id);

  INSERT INTO vibetype_private.notification (channel, payload) VALUES (
    'account_registration',
    jsonb_pretty(jsonb_build_object(
      'account', row_to_json(_new_account_notify),
      'template', jsonb_build_object('language', account_registration.language)
    ))
  );

  -- not possible to return data here as this would make the silent return above for email address duplicates distinguishable from a successful registration
END;
$$;


ALTER FUNCTION vibetype.account_registration(birth_date date, email_address text, language text, legal_term_id uuid, password text, username text) OWNER TO ci;

--
-- Name: FUNCTION account_registration(birth_date date, email_address text, language text, legal_term_id uuid, password text, username text); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.account_registration(birth_date date, email_address text, language text, legal_term_id uuid, password text, username text) IS 'Creates a contact and registers an account referencing it.\n\nError codes:\n- **VTBDA** when the birth date is not at least 18 years old.\n- **VTPLL** when the password length does not reach its minimum.\n- **VTAUV** when an account with the given username already exists.';


--
-- Name: account_registration_refresh(uuid, text); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.account_registration_refresh(account_id uuid, language text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _new_account_notify RECORD;
BEGIN
  RAISE 'Refreshing registrations is currently not available due to missing rate limiting!' USING ERRCODE = 'deprecated_feature';

  IF (NOT EXISTS (SELECT 1 FROM vibetype_private.account WHERE account.id = account_registration_refresh.account_id)) THEN
    RAISE 'An account with this account id does not exist!' USING ERRCODE = 'invalid_parameter_value';
  END IF;

  WITH updated AS (
    UPDATE vibetype_private.account
      SET email_address_verification = DEFAULT
      WHERE account.id = account_registration_refresh.account_id
      RETURNING *
  ) SELECT
    account.username,
    updated.email_address,
    updated.email_address_verification,
    updated.email_address_verification_valid_until
    INTO _new_account_notify
    FROM updated, vibetype.account
    WHERE updated.id = account.id;

  INSERT INTO vibetype_private.notification (channel, payload) VALUES (
    'account_registration',
    jsonb_pretty(jsonb_build_object(
      'account', row_to_json(_new_account_notify),
      'template', jsonb_build_object('language', account_registration_refresh.language)
    ))
  );
END;
$$;


ALTER FUNCTION vibetype.account_registration_refresh(account_id uuid, language text) OWNER TO ci;

--
-- Name: FUNCTION account_registration_refresh(account_id uuid, language text); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.account_registration_refresh(account_id uuid, language text) IS 'Refreshes an account''s email address verification validity period.\n\nError codes:\n- **01P01** in all cases right now as refreshing registrations is currently not available due to missing rate limiting.\n- **22023** when an account with this account id does not exist.';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.account (
    id uuid NOT NULL,
    description text,
    imprint text,
    username text NOT NULL,
    CONSTRAINT account_description_check CHECK ((char_length(description) < 1000)),
    CONSTRAINT account_imprint_check CHECK ((char_length(imprint) < 10000)),
    CONSTRAINT account_username_check CHECK (((char_length(username) < 100) AND (username ~ '^[-A-Za-z0-9]+$'::text)))
);


ALTER TABLE vibetype.account OWNER TO ci;

--
-- Name: TABLE account; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.account IS '@omit create,delete
Public account data.';


--
-- Name: COLUMN account.id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.account.id IS '@omit create,update
The account''s internal id.';


--
-- Name: COLUMN account.description; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.account.description IS 'The account''s description.';


--
-- Name: COLUMN account.imprint; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.account.imprint IS 'The account''s imprint.';


--
-- Name: COLUMN account.username; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.account.username IS '@omit update
The account''s username.';


--
-- Name: account_search(text); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.account_search(search_string text) RETURNS SETOF vibetype.account
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM vibetype.account
  WHERE
    username ILIKE '%' || account_search.search_string || '%'
  ORDER BY
    username;
END;
$$;


ALTER FUNCTION vibetype.account_search(search_string text) OWNER TO ci;

--
-- Name: FUNCTION account_search(search_string text); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.account_search(search_string text) IS 'Returns all accounts with a username containing a given substring.';


--
-- Name: account_upload_quota_bytes(); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.account_upload_quota_bytes() RETURNS bigint
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
BEGIN
  RETURN (SELECT upload_quota_bytes FROM vibetype_private.account WHERE account.id = current_setting('jwt.claims.account_id')::UUID);
END;
$$;


ALTER FUNCTION vibetype.account_upload_quota_bytes() OWNER TO ci;

--
-- Name: FUNCTION account_upload_quota_bytes(); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.account_upload_quota_bytes() IS 'Gets the total upload quota in bytes for the invoking account.';


--
-- Name: achievement_unlock(uuid, text); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.achievement_unlock(code uuid, alias text) RETURNS uuid
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _account_id UUID;
  _achievement vibetype.achievement_type;
  _achievement_id UUID;
BEGIN
  _account_id := vibetype.invoker_account_id();

  SELECT achievement
    FROM vibetype_private.achievement_code
    INTO _achievement
    WHERE achievement_code.id = achievement_unlock.code OR achievement_code.alias = achievement_unlock.alias;

  IF (_achievement IS NULL) THEN
    RAISE 'Unknown achievement!' USING ERRCODE = 'no_data_found';
  END IF;

  IF (_account_id IS NULL) THEN
    RAISE 'Unknown account!' USING ERRCODE = 'no_data_found';
  END IF;

  _achievement_id := (
    SELECT id FROM vibetype.achievement
    WHERE achievement.account_id = _account_id AND achievement.achievement = _achievement
  );

  IF (_achievement_id IS NULL) THEN
    INSERT INTO vibetype.achievement(account_id, achievement)
      VALUES (_account_id,  _achievement)
      RETURNING achievement.id INTO _achievement_id;
  END IF;

  RETURN _achievement_id;
END;
$$;


ALTER FUNCTION vibetype.achievement_unlock(code uuid, alias text) OWNER TO ci;

--
-- Name: FUNCTION achievement_unlock(code uuid, alias text); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.achievement_unlock(code uuid, alias text) IS 'Inserts an achievement unlock for the user that gave an existing achievement code.\n\nError codes:\n- **P0002** when the achievement or the account is unknown.';


--
-- Name: authenticate(text, text); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.authenticate(username text, password text) RETURNS vibetype.jwt
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _account_id UUID;
  _jwt_id UUID := gen_random_uuid();
  _jwt_exp BIGINT := EXTRACT(EPOCH FROM ((SELECT date_trunc('second', CURRENT_TIMESTAMP::TIMESTAMP WITH TIME ZONE)) + COALESCE(current_setting('vibetype.jwt_expiry_duration', true), '1 day')::INTERVAL));
  _jwt vibetype.jwt;
  _username TEXT;
BEGIN
  IF (authenticate.username = '' AND authenticate.password = '') THEN
    -- Authenticate as guest.
    _jwt := (_jwt_id, NULL, NULL, _jwt_exp, vibetype.guest_claim_array(), 'vibetype_anonymous')::vibetype.jwt;
  ELSIF (authenticate.username IS NOT NULL AND authenticate.password IS NOT NULL) THEN
    -- if authenticate.username contains @ then treat it as an email adress otherwise as a user name
    IF (strpos(authenticate.username, '@') = 0) THEN
      SELECT id FROM vibetype.account WHERE account.username = authenticate.username INTO _account_id;
    ELSE
      SELECT id FROM vibetype_private.account WHERE account.email_address = authenticate.username INTO _account_id;
    END IF;

    IF (_account_id IS NULL) THEN
      RAISE 'Account not found!' USING ERRCODE = 'no_data_found';
    END IF;

    SELECT account.username INTO _username FROM vibetype.account WHERE id = _account_id;

    IF ((
        SELECT account.email_address_verification
        FROM vibetype_private.account
        WHERE
              account.id = _account_id
          AND account.password_hash = public.crypt(authenticate.password, account.password_hash)
      ) IS NOT NULL) THEN
      RAISE 'Account not verified!' USING ERRCODE = 'object_not_in_prerequisite_state';
    END IF;

    WITH updated AS (
      UPDATE vibetype_private.account
      SET (last_activity, password_reset_verification) = (DEFAULT, NULL)
      WHERE
            account.id = _account_id
        AND account.email_address_verification IS NULL -- Has been checked before, but better safe than sorry.
        AND account.password_hash = public.crypt(authenticate.password, account.password_hash)
      RETURNING *
    ) SELECT _jwt_id, updated.id, _username, _jwt_exp, NULL, 'vibetype_account'
      FROM updated
      INTO _jwt;

    IF (_jwt IS NULL) THEN
      RAISE 'Could not get token!' USING ERRCODE = 'no_data_found';
    END IF;
  END IF;

  INSERT INTO vibetype_private.jwt(id, token) VALUES (_jwt_id, _jwt);
  RETURN _jwt;
END;
$$;


ALTER FUNCTION vibetype.authenticate(username text, password text) OWNER TO ci;

--
-- Name: FUNCTION authenticate(username text, password text); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.authenticate(username text, password text) IS 'Creates a JWT token that will securely identify an account and give it certain permissions.\n\nError codes:\n- **P0002** when an account is not found or when the token could not be created.\n- **55000** when the account is not verified yet.';


--
-- Name: guest; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.guest (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    contact_id uuid NOT NULL,
    event_id uuid NOT NULL,
    feedback vibetype.invitation_feedback,
    feedback_paper vibetype.invitation_feedback_paper,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    updated_by uuid
);


ALTER TABLE vibetype.guest OWNER TO ci;

--
-- Name: TABLE guest; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.guest IS 'A guest for a contact. A bidirectional mapping between an event and a contact.';


--
-- Name: COLUMN guest.id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.guest.id IS '@omit create,update
The guests''s internal id.';


--
-- Name: COLUMN guest.contact_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.guest.contact_id IS 'The internal id of the guest''s contact.';


--
-- Name: COLUMN guest.event_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.guest.event_id IS 'The internal id of the guest''s event.';


--
-- Name: COLUMN guest.feedback; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.guest.feedback IS 'The guest''s general feedback status.';


--
-- Name: COLUMN guest.feedback_paper; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.guest.feedback_paper IS 'The guest''s paper feedback status.';


--
-- Name: COLUMN guest.created_at; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.guest.created_at IS '@omit create,update
Timestamp of when the guest was created, defaults to the current timestamp.';


--
-- Name: COLUMN guest.updated_at; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.guest.updated_at IS '@omit create,update
Timestamp of when the guest was last updated.';


--
-- Name: COLUMN guest.updated_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.guest.updated_by IS '@omit create,update
The id of the account which last updated the guest. `NULL` if the guest was updated by an anonymous user.';


--
-- Name: create_guests(uuid, uuid[]); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.create_guests(event_id uuid, contact_ids uuid[]) RETURNS SETOF vibetype.guest
    LANGUAGE plpgsql STRICT
    AS $$
DECLARE
  _contact_id UUID;
  _id UUID;
  _id_array UUID[] := ARRAY[]::UUID[];
BEGIN
  FOREACH _contact_id IN ARRAY create_guests.contact_ids LOOP
    INSERT INTO vibetype.guest(event_id, contact_id)
      VALUES (create_guests.event_id, _contact_id)
      RETURNING id INTO _id;

    _id_array := array_append(_id_array, _id);
  END LOOP;

  RETURN QUERY
    SELECT *
    FROM vibetype.guest
    WHERE id = ANY (_id_array);
END $$;


ALTER FUNCTION vibetype.create_guests(event_id uuid, contact_ids uuid[]) OWNER TO ci;

--
-- Name: FUNCTION create_guests(event_id uuid, contact_ids uuid[]); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.create_guests(event_id uuid, contact_ids uuid[]) IS 'Function for inserting multiple guest records.';


--
-- Name: event; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.event (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    address_id uuid,
    description text,
    "end" timestamp with time zone,
    guest_count_maximum integer,
    is_archived boolean DEFAULT false NOT NULL,
    is_in_person boolean,
    is_remote boolean,
    language vibetype.language,
    name text NOT NULL,
    slug text NOT NULL,
    start timestamp with time zone NOT NULL,
    url text,
    visibility vibetype.event_visibility NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid NOT NULL,
    search_vector tsvector,
    CONSTRAINT event_description_check CHECK (((char_length(description) > 0) AND (char_length(description) < 1000000))),
    CONSTRAINT event_guest_count_maximum_check CHECK ((guest_count_maximum > 0)),
    CONSTRAINT event_name_check CHECK (((char_length(name) > 0) AND (char_length(name) < 100))),
    CONSTRAINT event_slug_check CHECK (((char_length(slug) < 100) AND (slug ~ '^[-A-Za-z0-9]+$'::text))),
    CONSTRAINT event_url_check CHECK (((char_length(url) < 300) AND (url ~ '^https:\/\/'::text)))
);


ALTER TABLE vibetype.event OWNER TO ci;

--
-- Name: TABLE event; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.event IS 'An event.';


--
-- Name: COLUMN event.id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event.id IS '@omit create,update
The event''s internal id.';


--
-- Name: COLUMN event.address_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event.address_id IS 'Optional reference to the physical address of the event.';


--
-- Name: COLUMN event.description; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event.description IS 'The event''s description.';


--
-- Name: COLUMN event."end"; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event."end" IS 'The event''s end date and time, with timezone.';


--
-- Name: COLUMN event.guest_count_maximum; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event.guest_count_maximum IS 'The event''s maximum guest count.';


--
-- Name: COLUMN event.is_archived; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event.is_archived IS 'Indicates whether the event is archived.';


--
-- Name: COLUMN event.is_in_person; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event.is_in_person IS 'Indicates whether the event takes place in person.';


--
-- Name: COLUMN event.is_remote; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event.is_remote IS 'Indicates whether the event takes place remotely.';


--
-- Name: COLUMN event.name; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event.name IS 'The event''s name.';


--
-- Name: COLUMN event.slug; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event.slug IS 'The event''s name, slugified.';


--
-- Name: COLUMN event.start; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event.start IS 'The event''s start date and time, with timezone.';


--
-- Name: COLUMN event.url; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event.url IS 'The event''s unified resource locator.';


--
-- Name: COLUMN event.visibility; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event.visibility IS 'The event''s visibility.';


--
-- Name: COLUMN event.created_at; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event.created_at IS '@omit create,update
Timestamp of when the event was created, defaults to the current timestamp.';


--
-- Name: COLUMN event.created_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event.created_by IS 'The event creator''s id.';


--
-- Name: COLUMN event.search_vector; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event.search_vector IS '@omit
A vector used for full-text search on events.';


--
-- Name: event_delete(uuid, text); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.event_delete(id uuid, password text) RETURNS vibetype.event
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _current_account_id UUID;
  _event_deleted vibetype.event;
BEGIN
  _current_account_id := current_setting('jwt.claims.account_id')::UUID;

  IF (EXISTS (SELECT 1 FROM vibetype_private.account WHERE account.id = _current_account_id AND account.password_hash = public.crypt(event_delete.password, account.password_hash))) THEN
    DELETE
      FROM vibetype.event
      WHERE
            "event".id = event_delete.id
        AND "event".created_by = _current_account_id
      RETURNING * INTO _event_deleted;

    IF (_event_deleted IS NULL) THEN
      RAISE 'Event not found!' USING ERRCODE = 'no_data_found';
    ELSE
      RETURN _event_deleted;
    END IF;
  ELSE
    RAISE 'Account with given password not found!' USING ERRCODE = 'invalid_password';
  END IF;
END;
$$;


ALTER FUNCTION vibetype.event_delete(id uuid, password text) OWNER TO ci;

--
-- Name: FUNCTION event_delete(id uuid, password text); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.event_delete(id uuid, password text) IS 'Allows to delete an event.\n\nError codes:\n- **P0002** when the event was not found.\n- **28P01** when the account with the given password was not found.';


--
-- Name: event_guest_count_maximum(uuid); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.event_guest_count_maximum(event_id uuid) RETURNS integer
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
BEGIN
  RETURN (
    SELECT guest_count_maximum
    FROM vibetype.event
    WHERE
      id = event_guest_count_maximum.event_id
      AND ( -- Copied from `event_select` POLICY.
        (
          visibility = 'public'
          AND
          (
            guest_count_maximum IS NULL
            OR
            guest_count_maximum > (vibetype.guest_count(id)) -- Using the function here is required as there would otherwise be infinite recursion.
          )
        )
        OR (
          vibetype.invoker_account_id() IS NOT NULL
          AND
          created_by = vibetype.invoker_account_id()
        )
        OR id IN (SELECT vibetype_private.events_invited())
      )
  );
END
$$;


ALTER FUNCTION vibetype.event_guest_count_maximum(event_id uuid) OWNER TO ci;

--
-- Name: FUNCTION event_guest_count_maximum(event_id uuid); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.event_guest_count_maximum(event_id uuid) IS 'Add a function that returns the maximum guest count of an accessible event.';


--
-- Name: event_search(text, vibetype.language); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.event_search(query text, language vibetype.language) RETURNS SETOF vibetype.event
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  ts_config regconfig;
BEGIN
  ts_config := vibetype.language_iso_full_text_search(event_search.language);

  RETURN QUERY
  SELECT
    *
  FROM
    vibetype.event
  WHERE
    search_vector @@ websearch_to_tsquery(ts_config, event_search.query)
  ORDER BY
    ts_rank_cd(search_vector, websearch_to_tsquery(ts_config, event_search.query)) DESC;
END;
$$;


ALTER FUNCTION vibetype.event_search(query text, language vibetype.language) OWNER TO ci;

--
-- Name: FUNCTION event_search(query text, language vibetype.language); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.event_search(query text, language vibetype.language) IS 'Performs a full-text search on the event table based on the provided query and language, returning event IDs ordered by relevance.';


--
-- Name: event_unlock(uuid); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.event_unlock(guest_id uuid) RETURNS vibetype.event_unlock_response
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _jwt_id UUID;
  _jwt vibetype.jwt;
  _event vibetype.event;
  _event_creator_account_username TEXT;
  _event_id UUID;
BEGIN
  _jwt_id := current_setting('jwt.claims.id', true)::UUID;
  _jwt := (
    _jwt_id,
    vibetype.invoker_account_id(), -- prevent empty string cast to UUID
    current_setting('jwt.claims.account_username', true)::TEXT,
    current_setting('jwt.claims.exp', true)::BIGINT,
    (SELECT ARRAY(SELECT DISTINCT UNNEST(vibetype.guest_claim_array() || event_unlock.guest_id) ORDER BY 1)),
    current_setting('jwt.claims.role', true)::TEXT
  )::vibetype.jwt;

  UPDATE vibetype_private.jwt
  SET token = _jwt
  WHERE id = _jwt_id;

  _event_id := (
    SELECT event_id FROM vibetype.guest
    WHERE guest.id = event_unlock.guest_id
  );

  IF (_event_id IS NULL) THEN
    RAISE 'No guest for this guest id found!' USING ERRCODE = 'no_data_found';
  END IF;

  SELECT *
    INTO _event
    FROM vibetype.event
    WHERE id = _event_id;

  IF (_event IS NULL) THEN
    RAISE 'No event for this guest id found!' USING ERRCODE = 'no_data_found';
  END IF;

  _event_creator_account_username := (
    SELECT username
    FROM vibetype.account
    WHERE id = _event.created_by
  );

  IF (_event_creator_account_username IS NULL) THEN
    RAISE 'No event creator username for this guest id found!' USING ERRCODE = 'no_data_found';
  END IF;

  RETURN (_event_creator_account_username, _event.slug, _jwt)::vibetype.event_unlock_response;
END $$;


ALTER FUNCTION vibetype.event_unlock(guest_id uuid) OWNER TO ci;

--
-- Name: FUNCTION event_unlock(guest_id uuid); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.event_unlock(guest_id uuid) IS 'Adds a guest claim to the current session.\n\nError codes:\n- **P0002** when no guest, no event, or no event creator username was found for this guest id.';


--
-- Name: events_organized(); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.events_organized() RETURNS TABLE(event_id uuid)
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
BEGIN

  RETURN QUERY
    SELECT id FROM vibetype.event
    WHERE
      created_by = vibetype.invoker_account_id();
END
$$;


ALTER FUNCTION vibetype.events_organized() OWNER TO ci;

--
-- Name: FUNCTION events_organized(); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.events_organized() IS 'Add a function that returns all event ids for which the invoker is the creator.';


--
-- Name: guest_claim_array(); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.guest_claim_array() RETURNS uuid[]
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
DECLARE
  _guest_ids UUID[];
  _guest_ids_unblocked UUID[] := ARRAY[]::UUID[];
BEGIN
  _guest_ids := string_to_array(replace(btrim(current_setting('jwt.claims.guests', true), '[]'), '"', ''), ',')::UUID[];

  IF _guest_ids IS NOT NULL THEN
    _guest_ids_unblocked := ARRAY (
      SELECT g.id
      FROM vibetype.guest g
        JOIN vibetype.event e ON g.event_id = e.id
        JOIN vibetype.contact c ON g.contact_id = c.id
      WHERE g.id = ANY(_guest_ids)
        AND e.created_by NOT IN (
            SELECT id FROM vibetype_private.account_block_ids()
          )
        AND (
          c.created_by NOT IN (
            SELECT id FROM vibetype_private.account_block_ids()
          )
          AND (
            c.account_id IS NULL
            OR
            c.account_id NOT IN (
              SELECT id FROM vibetype_private.account_block_ids()
            )
          )
        )
    );
  ELSE
    _guest_ids_unblocked := ARRAY[]::UUID[];
  END IF;
  RETURN _guest_ids_unblocked;
END
$$;


ALTER FUNCTION vibetype.guest_claim_array() OWNER TO ci;

--
-- Name: FUNCTION guest_claim_array(); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.guest_claim_array() IS 'Returns the current guest claims as UUID array.';


--
-- Name: guest_contact_ids(); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.guest_contact_ids() RETURNS TABLE(contact_id uuid)
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
    -- get all contacts of guests
    SELECT g.contact_id
    FROM vibetype.guest g
    WHERE
      (
        -- that are known through a guest claim
        g.id = ANY (vibetype.guest_claim_array())
      OR
        -- or for events organized by the invoker
        g.event_id IN (SELECT vibetype.events_organized())
        and g.contact_id IN (
          SELECT id
          FROM vibetype.contact
          WHERE
            created_by NOT IN (
              SELECT id FROM vibetype_private.account_block_ids()
            )
            AND (
              account_id IS NULL
              OR
              account_id NOT IN (
                SELECT id FROM vibetype_private.account_block_ids()
              )
            )
        )
      );
END;
$$;


ALTER FUNCTION vibetype.guest_contact_ids() OWNER TO ci;

--
-- Name: FUNCTION guest_contact_ids(); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.guest_contact_ids() IS 'Returns contact ids that are accessible through guests.';


--
-- Name: guest_count(uuid); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.guest_count(event_id uuid) RETURNS integer
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
BEGIN
  RETURN (SELECT COUNT(1) FROM vibetype.guest WHERE guest.event_id = guest_count.event_id);
END;
$$;


ALTER FUNCTION vibetype.guest_count(event_id uuid) OWNER TO ci;

--
-- Name: FUNCTION guest_count(event_id uuid); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.guest_count(event_id uuid) IS 'Returns the guest count for an event.';


--
-- Name: invite(uuid, text); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.invite(guest_id uuid, language text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _contact RECORD;
  _email_address TEXT;
  _event RECORD;
  _event_creator_profile_picture_upload_id UUID;
  _event_creator_profile_picture_upload_storage_key TEXT;
  _event_creator_username TEXT;
  _guest RECORD;
BEGIN
  -- Guest UUID
  SELECT * INTO _guest FROM vibetype.guest WHERE guest.id = invite.guest_id;

  IF (
    _guest IS NULL
    OR
    _guest.event_id NOT IN (SELECT vibetype.events_organized()) -- Initial validation, every query below is expected to be secure.
  ) THEN
    RAISE 'Guest not accessible!' USING ERRCODE = 'no_data_found';
  END IF;

  -- Event
  SELECT
    id,
    address_id,
    description,
    "end",
    guest_count_maximum,
    is_archived,
    is_in_person,
    is_remote,
    name,
    slug,
    start,
    url,
    visibility,
    created_at,
    created_by
  INTO _event
  FROM vibetype.event
  WHERE "event".id = _guest.event_id;

  IF (_event IS NULL) THEN
    RAISE 'Event not accessible!' USING ERRCODE = 'no_data_found';
  END IF;

  -- Contact
  SELECT account_id, email_address INTO _contact FROM vibetype.contact WHERE contact.id = _guest.contact_id;

  IF (_contact IS NULL) THEN
    RAISE 'Contact not accessible!' USING ERRCODE = 'no_data_found';
  END IF;

  IF (_contact.account_id IS NULL) THEN
    IF (_contact.email_address IS NULL) THEN
      RAISE 'Contact email address not accessible!' USING ERRCODE = 'no_data_found';
    ELSE
      _email_address := _contact.email_address;
    END IF;
  ELSE
    -- Account
    SELECT email_address INTO _email_address FROM vibetype_private.account WHERE account.id = _contact.account_id;

    IF (_email_address IS NULL) THEN
      RAISE 'Account email address not accessible!' USING ERRCODE = 'no_data_found';
    END IF;
  END IF;

  -- Event creator username
  SELECT username INTO _event_creator_username FROM vibetype.account WHERE account.id = _event.created_by;

  -- Event creator profile picture storage key
  SELECT upload_id INTO _event_creator_profile_picture_upload_id FROM vibetype.profile_picture WHERE profile_picture.account_id = _event.created_by;
  SELECT storage_key INTO _event_creator_profile_picture_upload_storage_key FROM vibetype.upload WHERE upload.id = _event_creator_profile_picture_upload_id;

  INSERT INTO vibetype_private.notification (channel, payload)
    VALUES (
      'event_invitation',
      jsonb_pretty(jsonb_build_object(
        'data', jsonb_build_object(
          'emailAddress', _email_address,
          'event', _event,
          'eventCreatorProfilePictureUploadStorageKey', _event_creator_profile_picture_upload_storage_key,
          'eventCreatorUsername', _event_creator_username,
          'guestId', _guest.id
        ),
        'template', jsonb_build_object('language', invite.language)
      ))
    );
END;
$$;


ALTER FUNCTION vibetype.invite(guest_id uuid, language text) OWNER TO ci;

--
-- Name: FUNCTION invite(guest_id uuid, language text); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.invite(guest_id uuid, language text) IS 'Adds a notification for the invitation channel.\n\nError codes:\n- **P0002** when the guest, event, contact, the contact email address, or the account email address is not accessible.';


--
-- Name: invoker_account_id(); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.invoker_account_id() RETURNS uuid
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
BEGIN
  RETURN NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID;
END;
$$;


ALTER FUNCTION vibetype.invoker_account_id() OWNER TO ci;

--
-- Name: FUNCTION invoker_account_id(); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.invoker_account_id() IS 'Returns the session''s account id.';


--
-- Name: jwt_refresh(uuid); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.jwt_refresh(jwt_id uuid) RETURNS vibetype.jwt
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _epoch_now BIGINT := EXTRACT(EPOCH FROM (SELECT date_trunc('second', CURRENT_TIMESTAMP::TIMESTAMP WITH TIME ZONE)));
  _jwt vibetype.jwt;
BEGIN
  SELECT (token).id, (token).account_id, (token).account_username, (token)."exp", (token).guests, (token).role
  INTO _jwt
  FROM vibetype_private.jwt
  WHERE   id = jwt_refresh.jwt_id
  AND     (token)."exp" >= _epoch_now;

  IF (_jwt IS NULL) THEN
    RETURN NULL;
  ELSE
    UPDATE vibetype_private.jwt
    SET token.exp = EXTRACT(EPOCH FROM ((SELECT date_trunc('second', CURRENT_TIMESTAMP::TIMESTAMP WITH TIME ZONE)) + COALESCE(current_setting('vibetype.jwt_expiry_duration', true), '1 day')::INTERVAL))
    WHERE id = jwt_refresh.jwt_id;

    UPDATE vibetype_private.account
    SET last_activity = DEFAULT
    WHERE account.id = _jwt.account_id;

    RETURN (
      SELECT token
      FROM vibetype_private.jwt
      WHERE   id = jwt_refresh.jwt_id
      AND     (token)."exp" >= _epoch_now
    );
  END IF;
END;
$$;


ALTER FUNCTION vibetype.jwt_refresh(jwt_id uuid) OWNER TO ci;

--
-- Name: FUNCTION jwt_refresh(jwt_id uuid); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.jwt_refresh(jwt_id uuid) IS 'Refreshes a JWT.';


--
-- Name: language_iso_full_text_search(vibetype.language); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.language_iso_full_text_search(language vibetype.language) RETURNS regconfig
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
BEGIN
  CASE language
    -- WHEN 'ar' THEN RETURN 'arabic';
    -- WHEN 'ca' THEN RETURN 'catalan';
    -- WHEN 'da' THEN RETURN 'danish';
    WHEN 'de' THEN RETURN 'german';
    -- WHEN 'el' THEN RETURN 'greek';
    WHEN 'en' THEN RETURN 'english';
    -- WHEN 'es' THEN RETURN 'spanish';
    -- WHEN 'eu' THEN RETURN 'basque';
    -- WHEN 'fi' THEN RETURN 'finnish';
    -- WHEN 'fr' THEN RETURN 'french';
    -- WHEN 'ga' THEN RETURN 'irish';
    -- WHEN 'hi' THEN RETURN 'hindi';
    -- WHEN 'hu' THEN RETURN 'hungarian';
    -- WHEN 'hy' THEN RETURN 'armenian';
    -- WHEN 'id' THEN RETURN 'indonesian';
    -- WHEN 'it' THEN RETURN 'italian';
    -- WHEN 'lt' THEN RETURN 'lithuanian';
    -- WHEN 'ne' THEN RETURN 'nepali';
    -- WHEN 'nl' THEN RETURN 'dutch';
    -- WHEN 'no' THEN RETURN 'norwegian';
    -- WHEN 'pt' THEN RETURN 'portuguese';
    -- WHEN 'ro' THEN RETURN 'romanian';
    -- WHEN 'ru' THEN RETURN 'russian';
    -- WHEN 'sr' THEN RETURN 'serbian';
    -- WHEN 'sv' THEN RETURN 'swedish';
    -- WHEN 'ta' THEN RETURN 'tamil';
    -- WHEN 'tr' THEN RETURN 'turkish';
    -- WHEN 'yi' THEN RETURN 'yiddish';
    ELSE RETURN 'simple';
  END CASE;
END;
$$;


ALTER FUNCTION vibetype.language_iso_full_text_search(language vibetype.language) OWNER TO ci;

--
-- Name: FUNCTION language_iso_full_text_search(language vibetype.language); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.language_iso_full_text_search(language vibetype.language) IS 'Maps an ISO language code to the corresponding PostgreSQL text search configuration. This function returns the appropriate text search configuration for supported languages, such as "german" for "de" and "english" for "en". If the language code is not explicitly handled, the function defaults to the "simple" configuration, which is a basic tokenizer that does not perform stemming or handle stop words. This ensures that full-text search can work with a wide range of languages even if specific optimizations are not available for some.';


--
-- Name: legal_term_change(); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.legal_term_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'Changes to legal terms are not allowed to keep historical integrity. Publish a new version instead.';
  RETURN NULL;
END;
$$;


ALTER FUNCTION vibetype.legal_term_change() OWNER TO ci;

--
-- Name: notification_acknowledge(uuid, boolean); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.notification_acknowledge(id uuid, is_acknowledged boolean) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
BEGIN
  IF (EXISTS (SELECT 1 FROM vibetype_private.notification WHERE "notification".id = notification_acknowledge.id)) THEN
    UPDATE vibetype_private.notification SET is_acknowledged = notification_acknowledge.is_acknowledged WHERE "notification".id = notification_acknowledge.id;
  ELSE
    RAISE 'Notification with given id not found!' USING ERRCODE = 'no_data_found';
  END IF;
END;
$$;


ALTER FUNCTION vibetype.notification_acknowledge(id uuid, is_acknowledged boolean) OWNER TO ci;

--
-- Name: FUNCTION notification_acknowledge(id uuid, is_acknowledged boolean); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.notification_acknowledge(id uuid, is_acknowledged boolean) IS 'Allows to set the acknowledgement state of a notification.\n\nError codes:\n- **P0002** when no notification with the given id is found.';


--
-- Name: profile_picture_set(uuid); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.profile_picture_set(upload_id uuid) RETURNS void
    LANGUAGE plpgsql STRICT
    AS $$
BEGIN
  INSERT INTO vibetype.profile_picture(account_id, upload_id)
  VALUES (
    current_setting('jwt.claims.account_id')::UUID,
    profile_picture_set.upload_id
  )
  ON CONFLICT (account_id)
  DO UPDATE
  SET upload_id = profile_picture_set.upload_id;
END;
$$;


ALTER FUNCTION vibetype.profile_picture_set(upload_id uuid) OWNER TO ci;

--
-- Name: FUNCTION profile_picture_set(upload_id uuid); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.profile_picture_set(upload_id uuid) IS 'Sets the picture with the given upload id as the invoker''s profile picture.';


--
-- Name: trigger_contact_update_account_id(); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.trigger_contact_update_account_id() RETURNS trigger
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  BEGIN
    IF (
      -- invoked without account id
      vibetype.invoker_account_id() IS NULL
      OR
      -- invoked with account id
      -- and
      (
        -- updating own account's contact
        OLD.account_id = vibetype.invoker_account_id()
        AND
        OLD.created_by = vibetype.invoker_account_id()
        AND
        (
          -- trying to detach from account
          NEW.account_id != OLD.account_id
          OR
          NEW.created_by != OLD.created_by
        )
      )
    ) THEN
      RAISE 'You cannot remove the association of your account''s own contact with your account.' USING ERRCODE = 'foreign_key_violation';
    END IF;

    RETURN NEW;
  END;
$$;


ALTER FUNCTION vibetype.trigger_contact_update_account_id() OWNER TO ci;

--
-- Name: FUNCTION trigger_contact_update_account_id(); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.trigger_contact_update_account_id() IS 'Prevents invalid updates to contacts.';


--
-- Name: trigger_event_search_vector(); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.trigger_event_search_vector() RETURNS trigger
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  ts_config regconfig;
BEGIN
  ts_config := vibetype.language_iso_full_text_search(NEW.language);

  NEW.search_vector :=
    setweight(to_tsvector(ts_config, NEW.name), 'A') ||
    setweight(to_tsvector(ts_config, coalesce(NEW.description, '')), 'B');

  RETURN NEW;
END;
$$;


ALTER FUNCTION vibetype.trigger_event_search_vector() OWNER TO ci;

--
-- Name: FUNCTION trigger_event_search_vector(); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.trigger_event_search_vector() IS 'Generates a search vector for the event based on the name and description columns, weighted by their relevance and language configuration.';


--
-- Name: trigger_guest_update(); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.trigger_guest_update() RETURNS trigger
    LANGUAGE plpgsql STRICT
    AS $$
DECLARE
  whitelisted_cols TEXT[] := ARRAY['feedback', 'feedback_paper'];
BEGIN
  IF
      TG_OP = 'UPDATE'
    AND ( -- Invited.
      OLD.id = ANY (vibetype.guest_claim_array())
      OR
      (
        vibetype.invoker_account_id() IS NOT NULL
        AND
        OLD.contact_id IN (
          SELECT id
          FROM vibetype.contact
          WHERE contact.account_id = vibetype.invoker_account_id()
        )
      )
    )
    AND
      EXISTS (
        SELECT 1
          FROM jsonb_each(to_jsonb(OLD)) AS pre, jsonb_each(to_jsonb(NEW)) AS post
          WHERE pre.key = post.key AND pre.value IS DISTINCT FROM post.value
          AND NOT (pre.key = ANY(whitelisted_cols))
      )
  THEN
    RAISE 'You''re only allowed to alter these rows: %!', whitelisted_cols USING ERRCODE = 'insufficient_privilege';
  ELSE
    NEW.updated_at = CURRENT_TIMESTAMP;
    NEW.updated_by = vibetype.invoker_account_id();
    RETURN NEW;
  END IF;
END $$;


ALTER FUNCTION vibetype.trigger_guest_update() OWNER TO ci;

--
-- Name: FUNCTION trigger_guest_update(); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.trigger_guest_update() IS 'Checks if the caller has permissions to alter the desired columns.';


--
-- Name: trigger_metadata_update(); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.trigger_metadata_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  NEW.updated_by = vibetype.invoker_account_id();

  RETURN NEW;
END;
$$;


ALTER FUNCTION vibetype.trigger_metadata_update() OWNER TO ci;

--
-- Name: FUNCTION trigger_metadata_update(); Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON FUNCTION vibetype.trigger_metadata_update() IS 'Trigger function to automatically update metadata fields `updated_at` and `updated_by` when a row is modified. Sets `updated_at` to the current timestamp and `updated_by` to the account ID of the invoker.';


--
-- Name: trigger_metadata_update_fcm(); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.trigger_metadata_update_fcm() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.fcm_token IS DISTINCT FROM OLD.fcm_token THEN
    RAISE EXCEPTION 'When updating a device, the FCM token''s value must stay the same. The update only updates the `updated_at` and `updated_by` metadata columns. If you want to update the FCM token for the device, recreate the device with a new FCM token.'
      USING ERRCODE = 'integrity_constraint_violation';
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION vibetype.trigger_metadata_update_fcm() OWNER TO ci;

--
-- Name: trigger_upload_insert(); Type: FUNCTION; Schema: vibetype; Owner: ci
--

CREATE FUNCTION vibetype.trigger_upload_insert() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  _current_usage BIGINT;
  _quota BIGINT;
BEGIN
  SELECT COALESCE(SUM(size_byte), 0)
    INTO _current_usage
    FROM vibetype.upload
    WHERE created_by = NEW.created_by;

  SELECT upload_quota_bytes
    INTO _quota
    FROM vibetype_private.account
    WHERE id = NEW.created_by;

  IF (_current_usage + NEW.size_byte) > _quota THEN
    RAISE 'Upload quota limit reached!' USING ERRCODE = 'disk_full';
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION vibetype.trigger_upload_insert() OWNER TO ci;

--
-- Name: account_block_ids(); Type: FUNCTION; Schema: vibetype_private; Owner: ci
--

CREATE FUNCTION vibetype_private.account_block_ids() RETURNS TABLE(id uuid)
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
    -- users blocked by the current user
    SELECT blocked_account_id
    FROM vibetype.account_block
    WHERE created_by = vibetype.invoker_account_id()
    UNION ALL
    -- users who blocked the current user
    SELECT created_by
    FROM vibetype.account_block
    WHERE blocked_account_id = vibetype.invoker_account_id();
END
$$;


ALTER FUNCTION vibetype_private.account_block_ids() OWNER TO ci;

--
-- Name: FUNCTION account_block_ids(); Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON FUNCTION vibetype_private.account_block_ids() IS 'Returns all account ids being blocked by the invoker and all accounts that blocked the invoker.';


--
-- Name: account_email_address_verification_valid_until(); Type: FUNCTION; Schema: vibetype_private; Owner: ci
--

CREATE FUNCTION vibetype_private.account_email_address_verification_valid_until() RETURNS trigger
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  BEGIN
    IF (NEW.email_address_verification IS NULL) THEN
      NEW.email_address_verification_valid_until = NULL;
    ELSE
      IF ((OLD IS NULL) OR (OLD.email_address_verification IS DISTINCT FROM NEW.email_address_verification)) THEN
        NEW.email_address_verification_valid_until = (SELECT (CURRENT_TIMESTAMP + INTERVAL '1 day')::TIMESTAMP WITH TIME ZONE);
      END IF;
    END IF;

    RETURN NEW;
  END;
$$;


ALTER FUNCTION vibetype_private.account_email_address_verification_valid_until() OWNER TO ci;

--
-- Name: FUNCTION account_email_address_verification_valid_until(); Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON FUNCTION vibetype_private.account_email_address_verification_valid_until() IS 'Sets the valid until column of the email address verification to it''s default value.';


--
-- Name: account_password_reset_verification_valid_until(); Type: FUNCTION; Schema: vibetype_private; Owner: ci
--

CREATE FUNCTION vibetype_private.account_password_reset_verification_valid_until() RETURNS trigger
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  BEGIN
    IF (NEW.password_reset_verification IS NULL) THEN
      NEW.password_reset_verification_valid_until = NULL;
    ELSE
      IF ((OLD IS NULL) OR (OLD.password_reset_verification IS DISTINCT FROM NEW.password_reset_verification)) THEN
        NEW.password_reset_verification_valid_until = (SELECT (CURRENT_TIMESTAMP + INTERVAL '2 hours')::TIMESTAMP WITH TIME ZONE);
      END IF;
    END IF;

    RETURN NEW;
  END;
$$;


ALTER FUNCTION vibetype_private.account_password_reset_verification_valid_until() OWNER TO ci;

--
-- Name: FUNCTION account_password_reset_verification_valid_until(); Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON FUNCTION vibetype_private.account_password_reset_verification_valid_until() IS 'Sets the valid until column of the email address verification to it''s default value.';


--
-- Name: adjust_audit_log_id_seq(); Type: FUNCTION; Schema: vibetype_private; Owner: ci
--

CREATE FUNCTION vibetype_private.adjust_audit_log_id_seq() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  _value_max INTEGER;
BEGIN
  SELECT MAX(id) INTO _value_max
    FROM vibetype_private.audit_log;

  PERFORM setval(
    'vibetype_private.audit_log_id_seq',
    CASE WHEN _value_max IS NOT NULL THEN _value_max + 1 ELSE 1 END,
    false
  );
END;
$$;


ALTER FUNCTION vibetype_private.adjust_audit_log_id_seq() OWNER TO ci;

--
-- Name: FUNCTION adjust_audit_log_id_seq(); Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON FUNCTION vibetype_private.adjust_audit_log_id_seq() IS 'Function resetting the current value of the sequence vibetype_private.audit_log_id_seq according to the content of table audit_log.';


--
-- Name: event_policy_select(); Type: FUNCTION; Schema: vibetype_private; Owner: ci
--

CREATE FUNCTION vibetype_private.event_policy_select() RETURNS SETOF vibetype.event
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
    SELECT * FROM vibetype.event e
    WHERE (
      (
        e.visibility = 'public'
        AND (
          e.guest_count_maximum IS NULL
          OR e.guest_count_maximum > vibetype.guest_count(e.id)
        )
        AND e.created_by NOT IN (
          SELECT id FROM vibetype_private.account_block_ids()
        )
      )
      OR (
        e.id IN (
          SELECT * FROM vibetype_private.events_invited()
        )
      )
    );
END
$$;


ALTER FUNCTION vibetype_private.event_policy_select() OWNER TO ci;

--
-- Name: events_invited(); Type: FUNCTION; Schema: vibetype_private; Owner: ci
--

CREATE FUNCTION vibetype_private.events_invited() RETURNS TABLE(event_id uuid)
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY

  -- get all events for guests
  SELECT g.event_id FROM vibetype.guest g
  WHERE
    (
      -- whose event ...
      g.event_id IN (
        SELECT id
        FROM vibetype.event
        WHERE
          -- is not created by ...
          created_by NOT IN (
            SELECT id FROM vibetype_private.account_block_ids()
          )
      )
      AND
      -- whose invitee
      g.contact_id IN (
        SELECT id
        FROM vibetype.contact
        WHERE
            -- is the requesting user
            account_id = vibetype.invoker_account_id()
          AND
            -- who is not invited by
            created_by NOT IN (
              SELECT id FROM vibetype_private.account_block_ids()
            )
      )
    )
    OR
      -- for which the requesting user knows the id
      g.id = ANY (vibetype.guest_claim_array());
END
$$;


ALTER FUNCTION vibetype_private.events_invited() OWNER TO ci;

--
-- Name: FUNCTION events_invited(); Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON FUNCTION vibetype_private.events_invited() IS 'Add a function that returns all event ids for which the invoker is invited.';


--
-- Name: trigger_audit_log(); Type: FUNCTION; Schema: vibetype_private; Owner: ci
--

CREATE FUNCTION vibetype_private.trigger_audit_log() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  _account_id UUID;
  _data_new JSONB;
  _data_old JSONB;
  _key TEXT;
  _user_name TEXT;
  _values_new JSONB;
  _values_old JSONB;
BEGIN
  _account_id := NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID;

  IF _account_id IS NULL THEN
    _user_name := current_user;
  ELSE
    SELECT username INTO _user_name
      FROM vibetype.account
      WHERE id = _account_id;
  END IF;

  _values_new := '{}';
  _values_old := '{}';

  IF TG_OP = 'INSERT' THEN
    _data_new := to_jsonb(NEW);
    _values_new := _data_new;

  ELSIF TG_OP = 'UPDATE' THEN
    _data_new := to_jsonb(NEW);
    _data_old := to_jsonb(OLD);

    FOR _key IN SELECT jsonb_object_keys(_data_new) INTERSECT SELECT jsonb_object_keys(_data_old)
    LOOP
      IF _data_new ->> _key != _data_old ->> _key THEN
        _values_new := _values_new || jsonb_build_object(_key, _data_new ->> _key);
        _values_old := _values_old || jsonb_build_object(_key, _data_old ->> _key);
      END IF;
    END LOOP;

  ELSIF TG_OP = 'DELETE' THEN
    _data_old := to_jsonb(OLD);
    _values_old := _data_old;

    FOR _key IN SELECT jsonb_object_keys(_data_old)
    LOOP
      _values_old := _values_old || jsonb_build_object(_key, _data_old ->> _key);
    END LOOP;

  END IF;

  IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
    INSERT INTO vibetype_private.audit_log (schema_name, table_name, record_id, operation_type, created_by, values_old, values_new)
      VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, NEW.id, TG_OP, _user_name, _values_old, _values_new);

    RETURN NEW;
  ELSE
    INSERT INTO vibetype_private.audit_log (schema_name, table_name, record_id, operation_type, created_by, values_old, _alues_new)
      VALUES (TG_TABLE_SCHEMA, TG_TABLE_NAME, OLD.id, TG_OP, _user_name, _values_old, _values_new);

    RETURN OLD;
  END IF;
END;
$$;


ALTER FUNCTION vibetype_private.trigger_audit_log() OWNER TO ci;

--
-- Name: FUNCTION trigger_audit_log(); Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON FUNCTION vibetype_private.trigger_audit_log() IS 'Generic audit trigger function creating records in table vibetype_private.audit_log.
inspired by https://medium.com/israeli-tech-radar/postgresql-trigger-based-audit-log-fd9d9d5e412c';


--
-- Name: trigger_audit_log_create(text, text); Type: FUNCTION; Schema: vibetype_private; Owner: ci
--

CREATE FUNCTION vibetype_private.trigger_audit_log_create(schema_name text, table_name text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  _trigger_name TEXT := 'z_indexed_audit_log_trigger';
BEGIN
  IF EXISTS(
    SELECT 1
      FROM pg_catalog.pg_class c
        JOIN pg_catalog.pg_attribute a ON c.oid = a.attrelid AND a.attname = 'id' -- audit log triggers works only for tables having an id column
        JOIN pg_catalog.pg_namespace n ON c.relnamespace = n.oid
      WHERE c.relkind = 'r'
        AND n.nspname = trigger_audit_log_create.schema_name
        AND c.relname = trigger_audit_log_create.table_name
        -- negative list, make sure that at least audit_log table is not audited
        AND (n.nspname, c.relname) not in (
          ('vibetype_private', 'audit_log'),
          ('vibetype_private', 'jwt')
        )
  ) THEN
    EXECUTE 'CREATE TRIGGER ' || _trigger_name ||
      ' BEFORE INSERT OR UPDATE OR DELETE ON ' ||
      trigger_audit_log_create.schema_name || '.' || trigger_audit_log_create.table_name ||
      ' FOR EACH ROW EXECUTE FUNCTION vibetype_private.trigger_audit_log()';
  ELSE
    RAISE EXCEPTION 'Table %.% cannot have an audit log trigger.',
      trigger_audit_log_create.schema_name, trigger_audit_log_create.table_name
      USING ERRCODE = 'VTALT';
  END IF;
END;
$$;


ALTER FUNCTION vibetype_private.trigger_audit_log_create(schema_name text, table_name text) OWNER TO ci;

--
-- Name: FUNCTION trigger_audit_log_create(schema_name text, table_name text); Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON FUNCTION vibetype_private.trigger_audit_log_create(schema_name text, table_name text) IS 'Function creating an audit log trigger for a single table.\n\nError codes:\n- **VTALT** when a table cannot have an audit log trigger.';


--
-- Name: trigger_audit_log_create_multiple(); Type: FUNCTION; Schema: vibetype_private; Owner: ci
--

CREATE FUNCTION vibetype_private.trigger_audit_log_create_multiple() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  _record RECORD;
  _trigger_name TEXT := 'z_indexed_audit_log_trigger'; -- PostgreSql Documentation, section 37.1: If more than one trigger is defined for the same event on the same relation, the triggers will be fired in alphabetical order by trigger name.
BEGIN
  FOR _record IN
    SELECT n.nspname ,c.relname
      FROM pg_catalog.pg_class c
        -- audit log triggers works only for tables having an id column
        JOIN pg_catalog.pg_attribute a ON c.oid = a.attrelid AND a.attname = 'id'
        JOIN pg_catalog.pg_namespace n ON c.relnamespace = n.oid
      WHERE c.relkind = 'r' AND n.nspname IN ('vibetype', 'vibetype_private')
        -- negative list, make sure that at least audit_log table is not audited
        AND (n.nspname, c.relname) NOT IN (
          ('vibetype_private', 'audit_log'),
          ('vibetype_private', 'jwt')
        )
  LOOP
     EXECUTE 'CREATE TRIGGER ' || _trigger_name ||
        ' BEFORE INSERT OR UPDATE OR DELETE ON ' ||
        _record.nspname || '.' || _record.relname ||
        ' FOR EACH ROW EXECUTE FUNCTION vibetype_private.trigger_audit_log()';
  END LOOP;
END;
$$;


ALTER FUNCTION vibetype_private.trigger_audit_log_create_multiple() OWNER TO ci;

--
-- Name: FUNCTION trigger_audit_log_create_multiple(); Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON FUNCTION vibetype_private.trigger_audit_log_create_multiple() IS 'Function creating all audit log triggers for all tables that should be audited.';


--
-- Name: trigger_audit_log_disable(text, text); Type: FUNCTION; Schema: vibetype_private; Owner: ci
--

CREATE FUNCTION vibetype_private.trigger_audit_log_disable(schema_name text, table_name text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  _record RECORD;
  _i INTEGER := 0;
BEGIN
  FOR _record IN
    SELECT t.trigger_name, t.schema_name, t.table_name, t.trigger_enabled
      FROM vibetype_private.audit_log_trigger t
      WHERE t.schema_name = trigger_audit_log_disable.schema_name
        AND t.table_name = trigger_audit_log_disable.table_name
  LOOP
    _i := _i + 1;

    IF _record.trigger_enabled != 'D' THEN
      EXECUTE 'ALTER TABLE ' || _record.schema_name || '.' || _record.table_name || ' DISABLE TRIGGER ' || _record.trigger_name;
    END IF;
  END LOOP;

  IF _i = 0 THEN
    RAISE NOTICE 'WARNING: Table %.% has no audit log trigger', trigger_audit_log_enable.schema_name, trigger_audit_log_enable.table_name;
  END IF;
END;
$$;


ALTER FUNCTION vibetype_private.trigger_audit_log_disable(schema_name text, table_name text) OWNER TO ci;

--
-- Name: FUNCTION trigger_audit_log_disable(schema_name text, table_name text); Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON FUNCTION vibetype_private.trigger_audit_log_disable(schema_name text, table_name text) IS 'Function disabling an audit log triggers that are currently enabled.';


--
-- Name: trigger_audit_log_disable_multiple(); Type: FUNCTION; Schema: vibetype_private; Owner: ci
--

CREATE FUNCTION vibetype_private.trigger_audit_log_disable_multiple() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  _record RECORD;
BEGIN
  FOR _record IN
    SELECT trigger_name, schema_name, table_name
      FROM vibetype_private.audit_log_trigger
      WHERE trigger_enabled != 'D'
  LOOP
    EXECUTE 'ALTER TABLE ' || _record.schema_name || '.' || _record.table_name || ' DISABLE TRIGGER ' || _record.trigger_name;
  END LOOP;
END;
$$;


ALTER FUNCTION vibetype_private.trigger_audit_log_disable_multiple() OWNER TO ci;

--
-- Name: FUNCTION trigger_audit_log_disable_multiple(); Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON FUNCTION vibetype_private.trigger_audit_log_disable_multiple() IS 'Function disabling all audit log triggers that are currently enabled.';


--
-- Name: trigger_audit_log_drop(text, text); Type: FUNCTION; Schema: vibetype_private; Owner: ci
--

CREATE FUNCTION vibetype_private.trigger_audit_log_drop(schema_name text, table_name text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  _record RECORD;
  _i INTEGER := 0;
BEGIN
  FOR _record IN
    SELECT t.trigger_name, t.schema_name, t.table_name
      FROM vibetype_private.audit_log_trigger t
      WHERE t.schema_name = trigger_audit_log_drop.schema_name
        AND t.table_name = trigger_audit_log_drop.table_name
  LOOP
    _i := _i + 1;

    EXECUTE 'DROP TRIGGER ' || _record.trigger_name || ' ON ' ||
      _record.schema_name || '.' || _record.table_name;
  END LOOP;

  IF _i = 0 THEN
    RAISE NOTICE 'WARNING: Table %.% had no audit log trigger',
      trigger_audit_log_drop.schema_name, trigger_audit_log_drop.table_name;
  END IF;
END;
$$;


ALTER FUNCTION vibetype_private.trigger_audit_log_drop(schema_name text, table_name text) OWNER TO ci;

--
-- Name: FUNCTION trigger_audit_log_drop(schema_name text, table_name text); Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON FUNCTION vibetype_private.trigger_audit_log_drop(schema_name text, table_name text) IS 'Function dropping all audit log triggers for a single table.';


--
-- Name: trigger_audit_log_drop_multiple(); Type: FUNCTION; Schema: vibetype_private; Owner: ci
--

CREATE FUNCTION vibetype_private.trigger_audit_log_drop_multiple() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  _record RECORD;
BEGIN
  FOR _record IN
    SELECT trigger_name, schema_name, table_name
      FROM vibetype_private.audit_log_trigger
  LOOP
    EXECUTE 'DROP TRIGGER ' || _record.trigger_name || ' ON ' || _record.schema_name || '.' || _record.table_name;
  END LOOP;
END;
$$;


ALTER FUNCTION vibetype_private.trigger_audit_log_drop_multiple() OWNER TO ci;

--
-- Name: FUNCTION trigger_audit_log_drop_multiple(); Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON FUNCTION vibetype_private.trigger_audit_log_drop_multiple() IS 'Function dropping all audit log triggers for all tables that are currently audited.';


--
-- Name: trigger_audit_log_enable(text, text); Type: FUNCTION; Schema: vibetype_private; Owner: ci
--

CREATE FUNCTION vibetype_private.trigger_audit_log_enable(schema_name text, table_name text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  _record RECORD;
  _i INTEGER := 0;
BEGIN
  FOR _record IN
    SELECT t.trigger_name, t.schema_name, t.table_name, t.trigger_enabled
      FROM vibetype_private.audit_log_trigger t
      WHERE t.schema_name = trigger_audit_log_enable.schema_name
        AND t.table_name = trigger_audit_log_enable.table_name
  LOOP
    _i := _i + 1;

    IF _record.trigger_enabled = 'D' THEN
      EXECUTE 'ALTER TABLE ' || _record.schema_name || '.' || _record.table_name || ' ENABLE TRIGGER ' || _record.trigger_name;
    END IF;
  END LOOP;

  IF _i = 0 THEN
    RAISE NOTICE 'WARNING: Table %.% has no audit log trigger', trigger_audit_log_enable.schema_name, trigger_audit_log_enable.table_name;
  END IF;
END;
$$;


ALTER FUNCTION vibetype_private.trigger_audit_log_enable(schema_name text, table_name text) OWNER TO ci;

--
-- Name: FUNCTION trigger_audit_log_enable(schema_name text, table_name text); Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON FUNCTION vibetype_private.trigger_audit_log_enable(schema_name text, table_name text) IS 'Function enabling audit log triggers for a single table.';


--
-- Name: trigger_audit_log_enable_multiple(); Type: FUNCTION; Schema: vibetype_private; Owner: ci
--

CREATE FUNCTION vibetype_private.trigger_audit_log_enable_multiple() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  _record RECORD;
BEGIN
  FOR _record IN
    SELECT trigger_name, schema_name, table_name
      FROM vibetype_private.audit_log_trigger
      WHERE trigger_enabled = 'D'
  LOOP
    EXECUTE 'ALTER TABLE ' || _record.schema_name || '.' || _record.table_name || ' ENABLE TRIGGER ' || _record.trigger_name;
  END LOOP;
END;
$$;


ALTER FUNCTION vibetype_private.trigger_audit_log_enable_multiple() OWNER TO ci;

--
-- Name: FUNCTION trigger_audit_log_enable_multiple(); Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON FUNCTION vibetype_private.trigger_audit_log_enable_multiple() IS 'Function enabling all audit log triggers that are currently disabled.';


--
-- Name: changes; Type: TABLE; Schema: sqitch; Owner: ci
--

CREATE TABLE sqitch.changes (
    change_id text NOT NULL,
    script_hash text,
    change text NOT NULL,
    project text NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    committed_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    committer_name text NOT NULL,
    committer_email text NOT NULL,
    planned_at timestamp with time zone NOT NULL,
    planner_name text NOT NULL,
    planner_email text NOT NULL
);


ALTER TABLE sqitch.changes OWNER TO ci;

--
-- Name: TABLE changes; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON TABLE sqitch.changes IS 'Tracks the changes currently deployed to the database.';


--
-- Name: COLUMN changes.change_id; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.changes.change_id IS 'Change primary key.';


--
-- Name: COLUMN changes.script_hash; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.changes.script_hash IS 'Deploy script SHA-1 hash.';


--
-- Name: COLUMN changes.change; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.changes.change IS 'Name of a deployed change.';


--
-- Name: COLUMN changes.project; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.changes.project IS 'Name of the Sqitch project to which the change belongs.';


--
-- Name: COLUMN changes.note; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.changes.note IS 'Description of the change.';


--
-- Name: COLUMN changes.committed_at; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.changes.committed_at IS 'Date the change was deployed.';


--
-- Name: COLUMN changes.committer_name; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.changes.committer_name IS 'Name of the user who deployed the change.';


--
-- Name: COLUMN changes.committer_email; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.changes.committer_email IS 'Email address of the user who deployed the change.';


--
-- Name: COLUMN changes.planned_at; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.changes.planned_at IS 'Date the change was added to the plan.';


--
-- Name: COLUMN changes.planner_name; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.changes.planner_name IS 'Name of the user who planed the change.';


--
-- Name: COLUMN changes.planner_email; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.changes.planner_email IS 'Email address of the user who planned the change.';


--
-- Name: dependencies; Type: TABLE; Schema: sqitch; Owner: ci
--

CREATE TABLE sqitch.dependencies (
    change_id text NOT NULL,
    type text NOT NULL,
    dependency text NOT NULL,
    dependency_id text,
    CONSTRAINT dependencies_check CHECK ((((type = 'require'::text) AND (dependency_id IS NOT NULL)) OR ((type = 'conflict'::text) AND (dependency_id IS NULL))))
);


ALTER TABLE sqitch.dependencies OWNER TO ci;

--
-- Name: TABLE dependencies; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON TABLE sqitch.dependencies IS 'Tracks the currently satisfied dependencies.';


--
-- Name: COLUMN dependencies.change_id; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.dependencies.change_id IS 'ID of the depending change.';


--
-- Name: COLUMN dependencies.type; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.dependencies.type IS 'Type of dependency.';


--
-- Name: COLUMN dependencies.dependency; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.dependencies.dependency IS 'Dependency name.';


--
-- Name: COLUMN dependencies.dependency_id; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.dependencies.dependency_id IS 'Change ID the dependency resolves to.';


--
-- Name: events; Type: TABLE; Schema: sqitch; Owner: ci
--

CREATE TABLE sqitch.events (
    event text NOT NULL,
    change_id text NOT NULL,
    change text NOT NULL,
    project text NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    requires text[] DEFAULT '{}'::text[] NOT NULL,
    conflicts text[] DEFAULT '{}'::text[] NOT NULL,
    tags text[] DEFAULT '{}'::text[] NOT NULL,
    committed_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    committer_name text NOT NULL,
    committer_email text NOT NULL,
    planned_at timestamp with time zone NOT NULL,
    planner_name text NOT NULL,
    planner_email text NOT NULL,
    CONSTRAINT events_event_check CHECK ((event = ANY (ARRAY['deploy'::text, 'revert'::text, 'fail'::text, 'merge'::text])))
);


ALTER TABLE sqitch.events OWNER TO ci;

--
-- Name: TABLE events; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON TABLE sqitch.events IS 'Contains full history of all deployment events.';


--
-- Name: COLUMN events.event; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.events.event IS 'Type of event.';


--
-- Name: COLUMN events.change_id; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.events.change_id IS 'Change ID.';


--
-- Name: COLUMN events.change; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.events.change IS 'Change name.';


--
-- Name: COLUMN events.project; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.events.project IS 'Name of the Sqitch project to which the change belongs.';


--
-- Name: COLUMN events.note; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.events.note IS 'Description of the change.';


--
-- Name: COLUMN events.requires; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.events.requires IS 'Array of the names of required changes.';


--
-- Name: COLUMN events.conflicts; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.events.conflicts IS 'Array of the names of conflicting changes.';


--
-- Name: COLUMN events.tags; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.events.tags IS 'Tags associated with the change.';


--
-- Name: COLUMN events.committed_at; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.events.committed_at IS 'Date the event was committed.';


--
-- Name: COLUMN events.committer_name; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.events.committer_name IS 'Name of the user who committed the event.';


--
-- Name: COLUMN events.committer_email; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.events.committer_email IS 'Email address of the user who committed the event.';


--
-- Name: COLUMN events.planned_at; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.events.planned_at IS 'Date the event was added to the plan.';


--
-- Name: COLUMN events.planner_name; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.events.planner_name IS 'Name of the user who planed the change.';


--
-- Name: COLUMN events.planner_email; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.events.planner_email IS 'Email address of the user who plan planned the change.';


--
-- Name: projects; Type: TABLE; Schema: sqitch; Owner: ci
--

CREATE TABLE sqitch.projects (
    project text NOT NULL,
    uri text,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    creator_name text NOT NULL,
    creator_email text NOT NULL
);


ALTER TABLE sqitch.projects OWNER TO ci;

--
-- Name: TABLE projects; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON TABLE sqitch.projects IS 'Sqitch projects deployed to this database.';


--
-- Name: COLUMN projects.project; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.projects.project IS 'Unique Name of a project.';


--
-- Name: COLUMN projects.uri; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.projects.uri IS 'Optional project URI';


--
-- Name: COLUMN projects.created_at; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.projects.created_at IS 'Date the project was added to the database.';


--
-- Name: COLUMN projects.creator_name; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.projects.creator_name IS 'Name of the user who added the project.';


--
-- Name: COLUMN projects.creator_email; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.projects.creator_email IS 'Email address of the user who added the project.';


--
-- Name: releases; Type: TABLE; Schema: sqitch; Owner: ci
--

CREATE TABLE sqitch.releases (
    version real NOT NULL,
    installed_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    installer_name text NOT NULL,
    installer_email text NOT NULL
);


ALTER TABLE sqitch.releases OWNER TO ci;

--
-- Name: TABLE releases; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON TABLE sqitch.releases IS 'Sqitch registry releases.';


--
-- Name: COLUMN releases.version; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.releases.version IS 'Version of the Sqitch registry.';


--
-- Name: COLUMN releases.installed_at; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.releases.installed_at IS 'Date the registry release was installed.';


--
-- Name: COLUMN releases.installer_name; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.releases.installer_name IS 'Name of the user who installed the registry release.';


--
-- Name: COLUMN releases.installer_email; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.releases.installer_email IS 'Email address of the user who installed the registry release.';


--
-- Name: tags; Type: TABLE; Schema: sqitch; Owner: ci
--

CREATE TABLE sqitch.tags (
    tag_id text NOT NULL,
    tag text NOT NULL,
    project text NOT NULL,
    change_id text NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    committed_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    committer_name text NOT NULL,
    committer_email text NOT NULL,
    planned_at timestamp with time zone NOT NULL,
    planner_name text NOT NULL,
    planner_email text NOT NULL
);


ALTER TABLE sqitch.tags OWNER TO ci;

--
-- Name: TABLE tags; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON TABLE sqitch.tags IS 'Tracks the tags currently applied to the database.';


--
-- Name: COLUMN tags.tag_id; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.tags.tag_id IS 'Tag primary key.';


--
-- Name: COLUMN tags.tag; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.tags.tag IS 'Project-unique tag name.';


--
-- Name: COLUMN tags.project; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.tags.project IS 'Name of the Sqitch project to which the tag belongs.';


--
-- Name: COLUMN tags.change_id; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.tags.change_id IS 'ID of last change deployed before the tag was applied.';


--
-- Name: COLUMN tags.note; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.tags.note IS 'Description of the tag.';


--
-- Name: COLUMN tags.committed_at; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.tags.committed_at IS 'Date the tag was applied to the database.';


--
-- Name: COLUMN tags.committer_name; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.tags.committer_name IS 'Name of the user who applied the tag.';


--
-- Name: COLUMN tags.committer_email; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.tags.committer_email IS 'Email address of the user who applied the tag.';


--
-- Name: COLUMN tags.planned_at; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.tags.planned_at IS 'Date the tag was added to the plan.';


--
-- Name: COLUMN tags.planner_name; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.tags.planner_name IS 'Name of the user who planed the tag.';


--
-- Name: COLUMN tags.planner_email; Type: COMMENT; Schema: sqitch; Owner: ci
--

COMMENT ON COLUMN sqitch.tags.planner_email IS 'Email address of the user who planned the tag.';


--
-- Name: account_block; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.account_block (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    blocked_account_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid NOT NULL,
    CONSTRAINT account_block_check CHECK ((created_by <> blocked_account_id))
);


ALTER TABLE vibetype.account_block OWNER TO ci;

--
-- Name: TABLE account_block; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.account_block IS '@omit update
Blocking of one account by another.';


--
-- Name: COLUMN account_block.id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.account_block.id IS '@omit create
The account block''s internal id.';


--
-- Name: COLUMN account_block.blocked_account_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.account_block.blocked_account_id IS 'The account id of the user who is blocked.';


--
-- Name: COLUMN account_block.created_at; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.account_block.created_at IS '@omit create
Timestamp of when the account block was created.';


--
-- Name: COLUMN account_block.created_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.account_block.created_by IS 'The account id of the user who created the account block.';


--
-- Name: account_social_network; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.account_social_network (
    account_id uuid NOT NULL,
    social_network vibetype.social_network NOT NULL,
    social_network_username text NOT NULL
);


ALTER TABLE vibetype.account_social_network OWNER TO ci;

--
-- Name: TABLE account_social_network; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.account_social_network IS 'Links accounts to their social media profiles. Each entry represents a specific social network and associated username for an account.';


--
-- Name: COLUMN account_social_network.account_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.account_social_network.account_id IS 'The unique identifier of the account.';


--
-- Name: COLUMN account_social_network.social_network; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.account_social_network.social_network IS 'The social network to which the account is linked.';


--
-- Name: COLUMN account_social_network.social_network_username; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.account_social_network.social_network_username IS 'The username of the account on the specified social network.';


--
-- Name: achievement; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.achievement (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    account_id uuid NOT NULL,
    achievement vibetype.achievement_type NOT NULL,
    level integer DEFAULT 1 NOT NULL,
    CONSTRAINT achievement_level_check CHECK ((level > 0))
);


ALTER TABLE vibetype.achievement OWNER TO ci;

--
-- Name: TABLE achievement; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.achievement IS 'Achievements unlocked by users.';


--
-- Name: COLUMN achievement.id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.achievement.id IS 'The achievement unlock''s internal id.';


--
-- Name: COLUMN achievement.account_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.achievement.account_id IS 'The account which unlocked the achievement.';


--
-- Name: COLUMN achievement.achievement; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.achievement.achievement IS 'The unlock''s achievement.';


--
-- Name: COLUMN achievement.level; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.achievement.level IS 'The achievement unlock''s level.';


--
-- Name: address; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.address (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    city text,
    country text,
    line_1 text,
    line_2 text,
    location public.geography(Point,4326),
    name text NOT NULL,
    postal_code text,
    region text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid NOT NULL,
    updated_at timestamp with time zone,
    updated_by uuid,
    CONSTRAINT address_city_check CHECK (((char_length(city) > 0) AND (char_length(city) <= 300))),
    CONSTRAINT address_country_check CHECK (((char_length(country) > 0) AND (char_length(country) <= 300))),
    CONSTRAINT address_line_1_check CHECK (((char_length(line_1) > 0) AND (char_length(line_1) <= 300))),
    CONSTRAINT address_line_2_check CHECK (((char_length(line_2) > 0) AND (char_length(line_2) <= 300))),
    CONSTRAINT address_name_check CHECK (((char_length(name) > 0) AND (char_length(name) <= 300))),
    CONSTRAINT address_postal_code_check CHECK (((char_length(postal_code) > 0) AND (char_length(postal_code) <= 20))),
    CONSTRAINT address_region_check CHECK (((char_length(region) > 0) AND (char_length(region) <= 300)))
);


ALTER TABLE vibetype.address OWNER TO ci;

--
-- Name: TABLE address; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.address IS 'Stores detailed address information, including lines, city, state, country, and metadata.';


--
-- Name: COLUMN address.id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.address.id IS '@omit create,update
Primary key, uniquely identifies each address.';


--
-- Name: COLUMN address.city; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.address.city IS 'City of the address. Must be between 1 and 300 characters.';


--
-- Name: COLUMN address.country; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.address.country IS 'Country of the address. Must be between 1 and 300 characters.';


--
-- Name: COLUMN address.line_1; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.address.line_1 IS 'First line of the address (e.g., street address). Must be between 1 and 300 characters.';


--
-- Name: COLUMN address.line_2; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.address.line_2 IS 'Second line of the address, if needed. Must be between 1 and 300 characters.';


--
-- Name: COLUMN address.location; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.address.location IS 'The geographic location of the address.';


--
-- Name: COLUMN address.name; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.address.name IS 'Person or company name. Must be between 1 and 300 characters.';


--
-- Name: COLUMN address.postal_code; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.address.postal_code IS 'Postal or ZIP code for the address. Must be between 1 and 20 characters.';


--
-- Name: COLUMN address.region; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.address.region IS 'Region of the address (e.g., state, province, county, department or territory). Must be between 1 and 300 characters.';


--
-- Name: COLUMN address.created_at; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.address.created_at IS '@omit create,update
Timestamp when the address was created. Defaults to the current timestamp.';


--
-- Name: COLUMN address.created_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.address.created_by IS '@omit update
Reference to the account that created the address.';


--
-- Name: COLUMN address.updated_at; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.address.updated_at IS '@omit create,update
Timestamp when the address was last updated.';


--
-- Name: COLUMN address.updated_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.address.updated_by IS '@omit create,update
Reference to the account that last updated the address.';


--
-- Name: contact; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.contact (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    account_id uuid,
    address_id uuid,
    email_address text,
    email_address_hash text GENERATED ALWAYS AS (md5(lower("substring"(email_address, '\S(?:.*\S)*'::text)))) STORED,
    first_name text,
    language vibetype.language,
    last_name text,
    nickname text,
    note text,
    phone_number text,
    timezone text,
    url text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid NOT NULL,
    CONSTRAINT contact_email_address_check CHECK ((char_length(email_address) < 255)),
    CONSTRAINT contact_first_name_check CHECK (((char_length(first_name) > 0) AND (char_length(first_name) <= 100))),
    CONSTRAINT contact_last_name_check CHECK (((char_length(last_name) > 0) AND (char_length(last_name) <= 100))),
    CONSTRAINT contact_nickname_check CHECK (((char_length(nickname) > 0) AND (char_length(nickname) <= 100))),
    CONSTRAINT contact_note_check CHECK (((char_length(note) > 0) AND (char_length(note) <= 1000))),
    CONSTRAINT contact_phone_number_check CHECK ((phone_number ~ '^\+(?:[0-9] ?){6,14}[0-9]$'::text)),
    CONSTRAINT contact_timezone_check CHECK ((timezone ~ '^([+-](0[0-9]|1[0-4]):[0-5][0-9]|Z)$'::text)),
    CONSTRAINT contact_url_check CHECK (((char_length(url) <= 300) AND (url ~ '^https:\/\/'::text)))
);


ALTER TABLE vibetype.contact OWNER TO ci;

--
-- Name: TABLE contact; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.contact IS 'Stores contact information related to accounts, including personal details, communication preferences, and metadata.';


--
-- Name: COLUMN contact.id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.contact.id IS '@omit create,update
Primary key, uniquely identifies each contact.';


--
-- Name: COLUMN contact.account_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.contact.account_id IS 'Optional reference to an associated account.';


--
-- Name: COLUMN contact.address_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.contact.address_id IS 'Optional reference to the physical address of the contact.';


--
-- Name: COLUMN contact.email_address; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.contact.email_address IS 'Email address of the contact. Must be shorter than 256 characters.';


--
-- Name: COLUMN contact.email_address_hash; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.contact.email_address_hash IS '@omit create,update
Hash of the email address, generated using md5 on the lowercased trimmed version of the email. Useful to display a profile picture from Gravatar.';


--
-- Name: COLUMN contact.first_name; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.contact.first_name IS 'First name of the contact. Must be between 1 and 100 characters.';


--
-- Name: COLUMN contact.language; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.contact.language IS 'Reference to the preferred language of the contact.';


--
-- Name: COLUMN contact.last_name; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.contact.last_name IS 'Last name of the contact. Must be between 1 and 100 characters.';


--
-- Name: COLUMN contact.nickname; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.contact.nickname IS 'Nickname of the contact. Must be between 1 and 100 characters. Useful when the contact is not commonly referred to by their legal name.';


--
-- Name: COLUMN contact.note; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.contact.note IS 'Additional notes about the contact. Must be between 1 and 1.000 characters. Useful for providing context or distinguishing details if the name alone is insufficient.';


--
-- Name: COLUMN contact.phone_number; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.contact.phone_number IS 'The international phone number of the contact, formatted according to E.164 (https://wikipedia.org/wiki/E.164).';


--
-- Name: COLUMN contact.timezone; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.contact.timezone IS 'Timezone of the contact in ISO 8601 format, e.g., `+02:00`, `-05:30`, or `Z`.';


--
-- Name: COLUMN contact.url; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.contact.url IS 'URL associated with the contact, must start with "https://" and be up to 300 characters.';


--
-- Name: COLUMN contact.created_at; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.contact.created_at IS '@omit create,update
Timestamp when the contact was created. Defaults to the current timestamp.';


--
-- Name: COLUMN contact.created_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.contact.created_by IS 'Reference to the account that created this contact. Enforces cascading deletion.';


--
-- Name: device; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.device (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    fcm_token text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid NOT NULL,
    updated_at timestamp with time zone,
    updated_by uuid,
    CONSTRAINT device_fcm_token_check CHECK (((char_length(fcm_token) > 0) AND (char_length(fcm_token) < 300)))
);


ALTER TABLE vibetype.device OWNER TO ci;

--
-- Name: TABLE device; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.device IS 'A device that''s assigned to an account.';


--
-- Name: COLUMN device.id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.device.id IS '@omit create,update
The internal id of the device.';


--
-- Name: COLUMN device.fcm_token; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.device.fcm_token IS 'The Firebase Cloud Messaging token of the device that''s used to deliver notifications.';


--
-- Name: COLUMN device.created_at; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.device.created_at IS '@omit create,update
Timestamp when the device was created. Defaults to the current timestamp.';


--
-- Name: COLUMN device.created_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.device.created_by IS '@omit update
Reference to the account that created the device.';


--
-- Name: COLUMN device.updated_at; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.device.updated_at IS '@omit create,update
Timestamp when the device was last updated.';


--
-- Name: COLUMN device.updated_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.device.updated_by IS '@omit create,update
Reference to the account that last updated the device.';


--
-- Name: event_category; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.event_category (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL
);


ALTER TABLE vibetype.event_category OWNER TO ci;

--
-- Name: TABLE event_category; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.event_category IS '@omit create,update,delete
Event categories.';


--
-- Name: COLUMN event_category.id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_category.id IS 'The id of the event category.';


--
-- Name: COLUMN event_category.name; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_category.name IS 'A category name.';


--
-- Name: event_category_mapping; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.event_category_mapping (
    event_id uuid NOT NULL,
    category_id uuid NOT NULL
);


ALTER TABLE vibetype.event_category_mapping OWNER TO ci;

--
-- Name: TABLE event_category_mapping; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.event_category_mapping IS 'Mapping events to categories (M:N relationship).';


--
-- Name: COLUMN event_category_mapping.event_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_category_mapping.event_id IS 'An event id.';


--
-- Name: COLUMN event_category_mapping.category_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_category_mapping.category_id IS 'A category id.';


--
-- Name: event_favorite; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.event_favorite (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid NOT NULL
);


ALTER TABLE vibetype.event_favorite OWNER TO ci;

--
-- Name: TABLE event_favorite; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.event_favorite IS '@omit update
Stores user-specific event favorites, linking an event to the account that marked it as a favorite.';


--
-- Name: COLUMN event_favorite.id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_favorite.id IS '@omit create
Primary key, uniquely identifies each favorite entry.';


--
-- Name: COLUMN event_favorite.event_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_favorite.event_id IS 'Reference to the event that is marked as a favorite.';


--
-- Name: COLUMN event_favorite.created_at; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_favorite.created_at IS '@omit create
Timestamp when the favorite was created. Defaults to the current timestamp.';


--
-- Name: COLUMN event_favorite.created_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_favorite.created_by IS 'Reference to the account that created the event favorite.';


--
-- Name: event_format; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.event_format (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL
);


ALTER TABLE vibetype.event_format OWNER TO ci;

--
-- Name: TABLE event_format; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.event_format IS '@omit create,update,delete
Event formats.';


--
-- Name: COLUMN event_format.id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_format.id IS 'The id of the event format.';


--
-- Name: COLUMN event_format.name; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_format.name IS 'The name of the event format.';


--
-- Name: event_format_mapping; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.event_format_mapping (
    event_id uuid NOT NULL,
    format_id uuid NOT NULL
);


ALTER TABLE vibetype.event_format_mapping OWNER TO ci;

--
-- Name: TABLE event_format_mapping; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.event_format_mapping IS 'Mapping events to formats (M:N relationship).';


--
-- Name: COLUMN event_format_mapping.event_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_format_mapping.event_id IS 'An event id.';


--
-- Name: COLUMN event_format_mapping.format_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_format_mapping.format_id IS 'A format id.';


--
-- Name: event_recommendation; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.event_recommendation (
    account_id uuid NOT NULL,
    event_id uuid NOT NULL,
    score real,
    predicted_score real
);


ALTER TABLE vibetype.event_recommendation OWNER TO ci;

--
-- Name: TABLE event_recommendation; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.event_recommendation IS 'Events recommended to a user account (M:N relationship).';


--
-- Name: COLUMN event_recommendation.account_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_recommendation.account_id IS 'A user account id.';


--
-- Name: COLUMN event_recommendation.event_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_recommendation.event_id IS 'The predicted score of the recommendation.';


--
-- Name: COLUMN event_recommendation.score; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_recommendation.score IS 'An event id.';


--
-- Name: COLUMN event_recommendation.predicted_score; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_recommendation.predicted_score IS 'The score of the recommendation.';


--
-- Name: event_upload; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.event_upload (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid NOT NULL,
    is_header_image boolean,
    upload_id uuid NOT NULL
);


ALTER TABLE vibetype.event_upload OWNER TO ci;

--
-- Name: TABLE event_upload; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.event_upload IS 'Associates uploaded files with events.';


--
-- Name: COLUMN event_upload.id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_upload.id IS '@omit create,update
Primary key, uniquely identifies each event-upload association.';


--
-- Name: COLUMN event_upload.event_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_upload.event_id IS '@omit update
Reference to the event associated with the upload.';


--
-- Name: COLUMN event_upload.is_header_image; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_upload.is_header_image IS 'Optional boolean flag indicating if the upload is the header image for the event.';


--
-- Name: COLUMN event_upload.upload_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.event_upload.upload_id IS '@omit update
Reference to the uploaded file.';


--
-- Name: friendship; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.friendship (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    a_account_id uuid NOT NULL,
    b_account_id uuid NOT NULL,
    status vibetype.friendship_status DEFAULT 'requested'::vibetype.friendship_status NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid NOT NULL,
    updated_at timestamp with time zone,
    updated_by uuid,
    CONSTRAINT friendship_creator_participant CHECK (((created_by = a_account_id) OR (created_by = b_account_id))),
    CONSTRAINT friendship_creator_updater_difference CHECK ((created_by <> updated_by)),
    CONSTRAINT friendship_ordering CHECK ((a_account_id < b_account_id)),
    CONSTRAINT friendship_updater_participant CHECK (((updated_by IS NULL) OR (updated_by = a_account_id) OR (updated_by = b_account_id)))
);


ALTER TABLE vibetype.friendship OWNER TO ci;

--
-- Name: TABLE friendship; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.friendship IS 'A friend relation together with its status.';


--
-- Name: COLUMN friendship.id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.friendship.id IS '@omit create,update
The friend relation''s internal id.';


--
-- Name: COLUMN friendship.a_account_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.friendship.a_account_id IS '@omit update
The ''left'' side of the friend relation. It must be lexically less than the ''right'' side.';


--
-- Name: COLUMN friendship.b_account_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.friendship.b_account_id IS '@omit update
The ''right'' side of the friend relation. It must be lexically greater than the ''left'' side.';


--
-- Name: COLUMN friendship.status; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.friendship.status IS '@omit create
The status of the friend relation.';


--
-- Name: COLUMN friendship.created_at; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.friendship.created_at IS '@omit create,update
The timestamp when the friend relation was created.';


--
-- Name: COLUMN friendship.created_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.friendship.created_by IS '@omit update
The account that created the friend relation was created.';


--
-- Name: COLUMN friendship.updated_at; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.friendship.updated_at IS '@omit create,update
The timestamp when the friend relation''s status was updated.';


--
-- Name: COLUMN friendship.updated_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.friendship.updated_by IS '@omit create,update
The account that updated the friend relation''s status.';


--
-- Name: guest_flat; Type: VIEW; Schema: vibetype; Owner: ci
--

CREATE VIEW vibetype.guest_flat WITH (security_invoker='true') AS
 SELECT guest.id AS guest_id,
    guest.contact_id AS guest_contact_id,
    guest.event_id AS guest_event_id,
    guest.feedback AS guest_feedback,
    guest.feedback_paper AS guest_feedback_paper,
    contact.id AS contact_id,
    contact.account_id AS contact_account_id,
    contact.address_id AS contact_address_id,
    contact.email_address AS contact_email_address,
    contact.email_address_hash AS contact_email_address_hash,
    contact.first_name AS contact_first_name,
    contact.last_name AS contact_last_name,
    contact.phone_number AS contact_phone_number,
    contact.url AS contact_url,
    contact.created_by AS contact_created_by,
    event.id AS event_id,
    event.address_id AS event_address_id,
    event.description AS event_description,
    event.start AS event_start,
    event."end" AS event_end,
    event.guest_count_maximum AS event_guest_count_maximum,
    event.is_archived AS event_is_archived,
    event.is_in_person AS event_is_in_person,
    event.is_remote AS event_is_remote,
    event.name AS event_name,
    event.slug AS event_slug,
    event.url AS event_url,
    event.visibility AS event_visibility,
    event.created_by AS event_created_by
   FROM ((vibetype.guest
     JOIN vibetype.contact ON ((guest.contact_id = contact.id)))
     JOIN vibetype.event ON ((guest.event_id = event.id)));


ALTER VIEW vibetype.guest_flat OWNER TO ci;

--
-- Name: VIEW guest_flat; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON VIEW vibetype.guest_flat IS 'View returning flattened guests.';


--
-- Name: legal_term; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.legal_term (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    language character varying(5) DEFAULT 'en'::character varying NOT NULL,
    term text NOT NULL,
    version character varying(20) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT legal_term_language_check CHECK (((language)::text ~ '^[a-z]{2}(_[A-Z]{2})?$'::text)),
    CONSTRAINT legal_term_term_check CHECK (((char_length(term) > 0) AND (char_length(term) <= 500000))),
    CONSTRAINT legal_term_version_check CHECK (((version)::text ~ '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$'::text))
);


ALTER TABLE vibetype.legal_term OWNER TO ci;

--
-- Name: TABLE legal_term; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.legal_term IS '@omit create,update,delete
Legal terms like privacy policies or terms of service.';


--
-- Name: COLUMN legal_term.id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.legal_term.id IS 'Unique identifier for each legal term.';


--
-- Name: COLUMN legal_term.language; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.legal_term.language IS 'Language code in ISO 639-1 format with optional region (e.g., `en` for English, `en_GB` for British English)';


--
-- Name: COLUMN legal_term.term; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.legal_term.term IS 'Text of the legal term. Markdown is expected to be used. It must be non-empty and cannot exceed 500,000 characters.';


--
-- Name: COLUMN legal_term.version; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.legal_term.version IS 'Semantic versioning string to track changes to the legal terms (format: `X.Y.Z`).';


--
-- Name: COLUMN legal_term.created_at; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.legal_term.created_at IS 'Timestamp when the term was created. Set to the current time by default.';


--
-- Name: legal_term_acceptance; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.legal_term_acceptance (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    account_id uuid NOT NULL,
    legal_term_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE vibetype.legal_term_acceptance OWNER TO ci;

--
-- Name: TABLE legal_term_acceptance; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.legal_term_acceptance IS '@omit update,delete
Tracks each user account''s acceptance of legal terms and conditions.';


--
-- Name: COLUMN legal_term_acceptance.id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.legal_term_acceptance.id IS '@omit create
Unique identifier for this legal term acceptance record. Automatically generated for each new acceptance.';


--
-- Name: COLUMN legal_term_acceptance.account_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.legal_term_acceptance.account_id IS 'The user account ID that accepted the legal terms. If the account is deleted, this acceptance record will also be deleted.';


--
-- Name: COLUMN legal_term_acceptance.legal_term_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.legal_term_acceptance.legal_term_id IS 'The ID of the legal terms that were accepted. Deletion of these legal terms is restricted while they are still referenced in this table.';


--
-- Name: COLUMN legal_term_acceptance.created_at; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.legal_term_acceptance.created_at IS '@omit create
Timestamp showing when the legal terms were accepted, set automatically at the time of acceptance.';


--
-- Name: preference_event_category; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.preference_event_category (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    account_id uuid NOT NULL,
    category_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE vibetype.preference_event_category OWNER TO ci;

--
-- Name: TABLE preference_event_category; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.preference_event_category IS 'Event categories a user account is interested in (M:N relationship).';


--
-- Name: COLUMN preference_event_category.account_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.preference_event_category.account_id IS 'A user account id.';


--
-- Name: COLUMN preference_event_category.category_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.preference_event_category.category_id IS 'An event category id.';


--
-- Name: preference_event_format; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.preference_event_format (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    account_id uuid NOT NULL,
    format_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE vibetype.preference_event_format OWNER TO ci;

--
-- Name: TABLE preference_event_format; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.preference_event_format IS 'Event formats a user account is interested in (M:N relationship).';


--
-- Name: COLUMN preference_event_format.account_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.preference_event_format.account_id IS 'A user account id.';


--
-- Name: COLUMN preference_event_format.format_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.preference_event_format.format_id IS 'The id of an event format.';


--
-- Name: COLUMN preference_event_format.created_at; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.preference_event_format.created_at IS 'The timestammp when the record was created..';


--
-- Name: preference_event_location; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.preference_event_location (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    location public.geography(Point,4326) NOT NULL,
    radius double precision NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid NOT NULL,
    CONSTRAINT preference_event_location_radius_check CHECK ((radius > (0)::double precision))
);


ALTER TABLE vibetype.preference_event_location OWNER TO ci;

--
-- Name: TABLE preference_event_location; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.preference_event_location IS 'Stores preferred event locations for user accounts, including coordinates and search radius.';


--
-- Name: COLUMN preference_event_location.id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.preference_event_location.id IS '@omit create
Unique identifier for the preference record.';


--
-- Name: COLUMN preference_event_location.location; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.preference_event_location.location IS 'Geographical point representing the preferred location, derived from latitude and longitude.';


--
-- Name: COLUMN preference_event_location.radius; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.preference_event_location.radius IS 'Search radius in meters around the location where events are preferred. Must be positive.';


--
-- Name: COLUMN preference_event_location.created_at; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.preference_event_location.created_at IS '@omit create
Timestamp of when the event size preference was created, defaults to the current timestamp.';


--
-- Name: COLUMN preference_event_location.created_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.preference_event_location.created_by IS 'Reference to the account that created the location preference.';


--
-- Name: preference_event_size; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.preference_event_size (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    account_id uuid NOT NULL,
    event_size vibetype.event_size NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE vibetype.preference_event_size OWNER TO ci;

--
-- Name: TABLE preference_event_size; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.preference_event_size IS 'Table for the user accounts'' preferred event sizes (M:N relationship).';


--
-- Name: COLUMN preference_event_size.account_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.preference_event_size.account_id IS 'The account''s internal id.';


--
-- Name: COLUMN preference_event_size.event_size; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.preference_event_size.event_size IS 'A preferred event size.';


--
-- Name: COLUMN preference_event_size.created_at; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.preference_event_size.created_at IS '@omit create,update
Timestamp of when the event size preference was created, defaults to the current timestamp.';


--
-- Name: profile_picture; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.profile_picture (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    account_id uuid NOT NULL,
    upload_id uuid NOT NULL
);


ALTER TABLE vibetype.profile_picture OWNER TO ci;

--
-- Name: TABLE profile_picture; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.profile_picture IS 'Mapping of account ids to upload ids.';


--
-- Name: COLUMN profile_picture.id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.profile_picture.id IS '@omit create,update
The profile picture''s internal id.';


--
-- Name: COLUMN profile_picture.account_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.profile_picture.account_id IS 'The account''s id.';


--
-- Name: COLUMN profile_picture.upload_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.profile_picture.upload_id IS 'The upload''s id.';


--
-- Name: report; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.report (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    reason text NOT NULL,
    target_account_id uuid,
    target_event_id uuid,
    target_upload_id uuid,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid NOT NULL,
    CONSTRAINT report_check CHECK ((num_nonnulls(target_account_id, target_event_id, target_upload_id) = 1)),
    CONSTRAINT report_reason_check CHECK (((char_length(reason) > 0) AND (char_length(reason) < 2000)))
);


ALTER TABLE vibetype.report OWNER TO ci;

--
-- Name: TABLE report; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.report IS '@omit update,delete
Stores reports made by users on other users, events, or uploads for moderation purposes.';


--
-- Name: COLUMN report.id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.report.id IS '@omit create
Unique identifier for the report, generated randomly using UUIDs.';


--
-- Name: COLUMN report.reason; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.report.reason IS 'The reason for the report, provided by the reporting user. Must be non-empty and less than 2000 characters.';


--
-- Name: COLUMN report.target_account_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.report.target_account_id IS 'The ID of the account being reported, if applicable.';


--
-- Name: COLUMN report.target_event_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.report.target_event_id IS 'The ID of the event being reported, if applicable.';


--
-- Name: COLUMN report.target_upload_id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.report.target_upload_id IS 'The ID of the upload being reported, if applicable.';


--
-- Name: COLUMN report.created_at; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.report.created_at IS '@omit create
Timestamp of when the report was created, defaults to the current timestamp.';


--
-- Name: COLUMN report.created_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.report.created_by IS 'The ID of the user who created the report.';


--
-- Name: CONSTRAINT report_check ON report; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON CONSTRAINT report_check ON vibetype.report IS 'Ensures that the report targets exactly one element (account, event, or upload).';


--
-- Name: CONSTRAINT report_reason_check ON report; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON CONSTRAINT report_reason_check ON vibetype.report IS 'Ensures the reason field contains between 1 and 2000 characters.';


--
-- Name: upload; Type: TABLE; Schema: vibetype; Owner: ci
--

CREATE TABLE vibetype.upload (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text,
    size_byte bigint NOT NULL,
    storage_key text,
    type text DEFAULT 'image'::text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by uuid NOT NULL,
    CONSTRAINT upload_name_check CHECK (((char_length(name) > 0) AND (char_length(name) < 300))),
    CONSTRAINT upload_size_byte_check CHECK ((size_byte > 0))
);

ALTER TABLE ONLY vibetype.upload REPLICA IDENTITY FULL;


ALTER TABLE vibetype.upload OWNER TO ci;

--
-- Name: TABLE upload; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON TABLE vibetype.upload IS 'An upload.';


--
-- Name: COLUMN upload.id; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.upload.id IS '@omit create,update
The upload''s internal id.';


--
-- Name: COLUMN upload.name; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.upload.name IS 'The name of the uploaded file.';


--
-- Name: COLUMN upload.size_byte; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.upload.size_byte IS '@omit update
The upload''s size in bytes.';


--
-- Name: COLUMN upload.storage_key; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.upload.storage_key IS '@omit create,update
The upload''s storage key.';


--
-- Name: COLUMN upload.type; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.upload.type IS '@omit create,update
The type of the uploaded file, default is ''image''.';


--
-- Name: COLUMN upload.created_at; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.upload.created_at IS '@omit create,update
Timestamp of when the upload was created, defaults to the current timestamp.';


--
-- Name: COLUMN upload.created_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON COLUMN vibetype.upload.created_by IS 'The uploader''s account id.';


--
-- Name: account; Type: TABLE; Schema: vibetype_private; Owner: ci
--

CREATE TABLE vibetype_private.account (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    birth_date date,
    email_address text NOT NULL,
    email_address_verification uuid DEFAULT gen_random_uuid(),
    email_address_verification_valid_until timestamp with time zone,
    location public.geography(Point,4326),
    password_hash text NOT NULL,
    password_reset_verification uuid,
    password_reset_verification_valid_until timestamp with time zone,
    upload_quota_bytes bigint DEFAULT 10485760 NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    last_activity timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT account_email_address_check CHECK ((char_length(email_address) < 255))
);


ALTER TABLE vibetype_private.account OWNER TO ci;

--
-- Name: TABLE account; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON TABLE vibetype_private.account IS 'Private account data.';


--
-- Name: COLUMN account.id; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.account.id IS 'The account''s internal id.';


--
-- Name: COLUMN account.birth_date; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.account.birth_date IS 'The account owner''s date of birth.';


--
-- Name: COLUMN account.email_address; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.account.email_address IS 'The account''s email address for account related information.';


--
-- Name: COLUMN account.email_address_verification; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.account.email_address_verification IS 'The UUID used to verify an email address, or null if already verified.';


--
-- Name: COLUMN account.email_address_verification_valid_until; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.account.email_address_verification_valid_until IS 'The timestamp until which an email address verification is valid.';


--
-- Name: COLUMN account.location; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.account.location IS 'The account''s geometric location.';


--
-- Name: COLUMN account.password_hash; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.account.password_hash IS 'The account''s password, hashed and salted.';


--
-- Name: COLUMN account.password_reset_verification; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.account.password_reset_verification IS 'The UUID used to reset a password, or null if there is no pending reset request.';


--
-- Name: COLUMN account.password_reset_verification_valid_until; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.account.password_reset_verification_valid_until IS 'The timestamp until which a password reset is valid.';


--
-- Name: COLUMN account.upload_quota_bytes; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.account.upload_quota_bytes IS 'The account''s upload quota in bytes.';


--
-- Name: COLUMN account.created_at; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.account.created_at IS 'Timestamp at which the account was last active.';


--
-- Name: COLUMN account.last_activity; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.account.last_activity IS 'Timestamp at which the account last requested an access token.';


--
-- Name: achievement_code; Type: TABLE; Schema: vibetype_private; Owner: ci
--

CREATE TABLE vibetype_private.achievement_code (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    alias text NOT NULL,
    achievement vibetype.achievement_type NOT NULL,
    CONSTRAINT achievement_code_alias_check CHECK ((char_length(alias) < 1000))
);


ALTER TABLE vibetype_private.achievement_code OWNER TO ci;

--
-- Name: TABLE achievement_code; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON TABLE vibetype_private.achievement_code IS 'Codes that unlock achievements.';


--
-- Name: COLUMN achievement_code.id; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.achievement_code.id IS 'The code that unlocks an achievement.';


--
-- Name: COLUMN achievement_code.alias; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.achievement_code.alias IS 'An alternative code, e.g. human readable, that unlocks an achievement.';


--
-- Name: COLUMN achievement_code.achievement; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.achievement_code.achievement IS 'The achievement that is unlocked by the code.';


--
-- Name: audit_log; Type: TABLE; Schema: vibetype_private; Owner: ci
--

CREATE TABLE vibetype_private.audit_log (
    id integer NOT NULL,
    operation_type text NOT NULL,
    record_id text NOT NULL,
    schema_name text NOT NULL,
    table_name text NOT NULL,
    values_new jsonb,
    values_old jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_by text NOT NULL
);


ALTER TABLE vibetype_private.audit_log OWNER TO ci;

--
-- Name: TABLE audit_log; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON TABLE vibetype_private.audit_log IS 'Table for storing audit log records.';


--
-- Name: COLUMN audit_log.id; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.audit_log.id IS 'The audit log record''s internal id.';


--
-- Name: COLUMN audit_log.operation_type; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.audit_log.operation_type IS 'The operation which triggered the audit log record. Can be `INSERT`, `UPDATE`, or `DELETE`.';


--
-- Name: COLUMN audit_log.record_id; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.audit_log.record_id IS 'The primary key of the table record which triggered the audit log record.';


--
-- Name: COLUMN audit_log.schema_name; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.audit_log.schema_name IS 'The schema of the table which triggered this audit log record.';


--
-- Name: COLUMN audit_log.table_name; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.audit_log.table_name IS 'The operation on a table that triggered the audit log record.';


--
-- Name: COLUMN audit_log.values_new; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.audit_log.values_new IS 'The original values of the table record after the operation, `NULL` if operation is `DELETE`.';


--
-- Name: COLUMN audit_log.values_old; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.audit_log.values_old IS 'The original values of the table record before the operation, `NULL` if operation is `INSERT`.';


--
-- Name: COLUMN audit_log.created_at; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.audit_log.created_at IS 'The timestamp of when the audit log record was created.';


--
-- Name: COLUMN audit_log.created_by; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.audit_log.created_by IS 'The user that executed the operation on the table referred to by this audit log record.';


--
-- Name: audit_log_id_seq; Type: SEQUENCE; Schema: vibetype_private; Owner: ci
--

CREATE SEQUENCE vibetype_private.audit_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE vibetype_private.audit_log_id_seq OWNER TO ci;

--
-- Name: audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: vibetype_private; Owner: ci
--

ALTER SEQUENCE vibetype_private.audit_log_id_seq OWNED BY vibetype_private.audit_log.id;


--
-- Name: audit_log_trigger; Type: VIEW; Schema: vibetype_private; Owner: ci
--

CREATE VIEW vibetype_private.audit_log_trigger AS
 SELECT t.tgname AS trigger_name,
    n.nspname AS schema_name,
    c.relname AS table_name,
    t.tgenabled AS trigger_enabled,
    p.proname AS trigger_function
   FROM (((pg_trigger t
     JOIN pg_class c ON ((t.tgrelid = c.oid)))
     JOIN pg_namespace n ON ((c.relnamespace = n.oid)))
     JOIN pg_proc p ON ((t.tgfoid = p.oid)))
  WHERE ((t.tgname = 'z_indexed_audit_log_trigger'::name) AND (n.nspname = ANY (ARRAY['vibetype'::name, 'vibetype_private'::name])));


ALTER VIEW vibetype_private.audit_log_trigger OWNER TO ci;

--
-- Name: VIEW audit_log_trigger; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON VIEW vibetype_private.audit_log_trigger IS 'View showing all triggers named `z_indexed_audit_log_trigger` on tables in the `vibetype` or `vibetype_private` schema.';


--
-- Name: COLUMN audit_log_trigger.trigger_name; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.audit_log_trigger.trigger_name IS 'The name of the trigger, should be `z_indexed_audit_log_trigger`';


--
-- Name: COLUMN audit_log_trigger.schema_name; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.audit_log_trigger.schema_name IS 'The schema of the table for which this trigger was created.';


--
-- Name: COLUMN audit_log_trigger.table_name; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.audit_log_trigger.table_name IS 'The table for which this trigger was created.';


--
-- Name: COLUMN audit_log_trigger.trigger_enabled; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.audit_log_trigger.trigger_enabled IS 'A character indicating whether the trigger is enabled (`trigger_enabled != ''D''`) or disabled (`trigger_enabled = ''D''`).';


--
-- Name: COLUMN audit_log_trigger.trigger_function; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.audit_log_trigger.trigger_function IS 'The name of the function associated with the trigger.';


--
-- Name: jwt; Type: TABLE; Schema: vibetype_private; Owner: ci
--

CREATE TABLE vibetype_private.jwt (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    token vibetype.jwt NOT NULL
);


ALTER TABLE vibetype_private.jwt OWNER TO ci;

--
-- Name: TABLE jwt; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON TABLE vibetype_private.jwt IS 'A list of tokens.';


--
-- Name: COLUMN jwt.id; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.jwt.id IS 'The token''s id.';


--
-- Name: COLUMN jwt.token; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.jwt.token IS 'The token.';


--
-- Name: notification; Type: TABLE; Schema: vibetype_private; Owner: ci
--

CREATE TABLE vibetype_private.notification (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    channel text NOT NULL,
    is_acknowledged boolean,
    payload text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT notification_payload_check CHECK ((octet_length(payload) <= 8000))
);


ALTER TABLE vibetype_private.notification OWNER TO ci;

--
-- Name: TABLE notification; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON TABLE vibetype_private.notification IS 'A notification.';


--
-- Name: COLUMN notification.id; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.notification.id IS 'The notification''s internal id.';


--
-- Name: COLUMN notification.channel; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.notification.channel IS 'The notification''s channel.';


--
-- Name: COLUMN notification.is_acknowledged; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.notification.is_acknowledged IS 'Whether the notification was acknowledged.';


--
-- Name: COLUMN notification.payload; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.notification.payload IS 'The notification''s payload.';


--
-- Name: COLUMN notification.created_at; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON COLUMN vibetype_private.notification.created_at IS 'The timestamp of the notification''s creation.';


--
-- Name: audit_log id; Type: DEFAULT; Schema: vibetype_private; Owner: ci
--

ALTER TABLE ONLY vibetype_private.audit_log ALTER COLUMN id SET DEFAULT nextval('vibetype_private.audit_log_id_seq'::regclass);


--
-- Name: changes changes_pkey; Type: CONSTRAINT; Schema: sqitch; Owner: ci
--

ALTER TABLE ONLY sqitch.changes
    ADD CONSTRAINT changes_pkey PRIMARY KEY (change_id);


--
-- Name: changes changes_project_script_hash_key; Type: CONSTRAINT; Schema: sqitch; Owner: ci
--

ALTER TABLE ONLY sqitch.changes
    ADD CONSTRAINT changes_project_script_hash_key UNIQUE (project, script_hash);


--
-- Name: dependencies dependencies_pkey; Type: CONSTRAINT; Schema: sqitch; Owner: ci
--

ALTER TABLE ONLY sqitch.dependencies
    ADD CONSTRAINT dependencies_pkey PRIMARY KEY (change_id, dependency);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: sqitch; Owner: ci
--

ALTER TABLE ONLY sqitch.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (change_id, committed_at);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: sqitch; Owner: ci
--

ALTER TABLE ONLY sqitch.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (project);


--
-- Name: projects projects_uri_key; Type: CONSTRAINT; Schema: sqitch; Owner: ci
--

ALTER TABLE ONLY sqitch.projects
    ADD CONSTRAINT projects_uri_key UNIQUE (uri);


--
-- Name: releases releases_pkey; Type: CONSTRAINT; Schema: sqitch; Owner: ci
--

ALTER TABLE ONLY sqitch.releases
    ADD CONSTRAINT releases_pkey PRIMARY KEY (version);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: sqitch; Owner: ci
--

ALTER TABLE ONLY sqitch.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (tag_id);


--
-- Name: tags tags_project_tag_key; Type: CONSTRAINT; Schema: sqitch; Owner: ci
--

ALTER TABLE ONLY sqitch.tags
    ADD CONSTRAINT tags_project_tag_key UNIQUE (project, tag);


--
-- Name: account_block account_block_created_by_blocked_account_id_key; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.account_block
    ADD CONSTRAINT account_block_created_by_blocked_account_id_key UNIQUE (created_by, blocked_account_id);


--
-- Name: account_block account_block_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.account_block
    ADD CONSTRAINT account_block_pkey PRIMARY KEY (id);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: account_social_network account_social_network_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.account_social_network
    ADD CONSTRAINT account_social_network_pkey PRIMARY KEY (account_id, social_network);


--
-- Name: CONSTRAINT account_social_network_pkey ON account_social_network; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON CONSTRAINT account_social_network_pkey ON vibetype.account_social_network IS 'Ensures uniqueness by combining the account ID and social network, allowing each account to have a single entry per social network.';


--
-- Name: account account_username_key; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.account
    ADD CONSTRAINT account_username_key UNIQUE (username);


--
-- Name: achievement achievement_account_id_achievement_key; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.achievement
    ADD CONSTRAINT achievement_account_id_achievement_key UNIQUE (account_id, achievement);


--
-- Name: achievement achievement_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.achievement
    ADD CONSTRAINT achievement_pkey PRIMARY KEY (id);


--
-- Name: address address_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.address
    ADD CONSTRAINT address_pkey PRIMARY KEY (id);


--
-- Name: contact contact_created_by_account_id_key; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.contact
    ADD CONSTRAINT contact_created_by_account_id_key UNIQUE (created_by, account_id);


--
-- Name: CONSTRAINT contact_created_by_account_id_key ON contact; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON CONSTRAINT contact_created_by_account_id_key ON vibetype.contact IS 'Ensures the uniqueness of the combination of `created_by` and `account_id` for a contact.';


--
-- Name: contact contact_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.contact
    ADD CONSTRAINT contact_pkey PRIMARY KEY (id);


--
-- Name: device device_created_by_fcm_token_key; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.device
    ADD CONSTRAINT device_created_by_fcm_token_key UNIQUE (created_by, fcm_token);


--
-- Name: device device_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.device
    ADD CONSTRAINT device_pkey PRIMARY KEY (id);


--
-- Name: event_category_mapping event_category_mapping_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_category_mapping
    ADD CONSTRAINT event_category_mapping_pkey PRIMARY KEY (event_id, category_id);


--
-- Name: event_category event_category_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_category
    ADD CONSTRAINT event_category_pkey PRIMARY KEY (id);


--
-- Name: event event_created_by_slug_key; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event
    ADD CONSTRAINT event_created_by_slug_key UNIQUE (created_by, slug);


--
-- Name: event_favorite event_favorite_created_by_event_id_key; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_favorite
    ADD CONSTRAINT event_favorite_created_by_event_id_key UNIQUE (created_by, event_id);


--
-- Name: CONSTRAINT event_favorite_created_by_event_id_key ON event_favorite; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON CONSTRAINT event_favorite_created_by_event_id_key ON vibetype.event_favorite IS 'Ensures that each user can mark an event as a favorite only once.';


--
-- Name: event_favorite event_favorite_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_favorite
    ADD CONSTRAINT event_favorite_pkey PRIMARY KEY (id);


--
-- Name: event_format_mapping event_format_mapping_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_format_mapping
    ADD CONSTRAINT event_format_mapping_pkey PRIMARY KEY (event_id, format_id);


--
-- Name: event_format event_format_name_unique; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_format
    ADD CONSTRAINT event_format_name_unique UNIQUE (name);


--
-- Name: event_format event_format_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_format
    ADD CONSTRAINT event_format_pkey PRIMARY KEY (id);


--
-- Name: event event_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);


--
-- Name: event_recommendation event_recommendation_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_recommendation
    ADD CONSTRAINT event_recommendation_pkey PRIMARY KEY (account_id, event_id);


--
-- Name: event_upload event_upload_event_id_upload_id_key; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_upload
    ADD CONSTRAINT event_upload_event_id_upload_id_key UNIQUE (event_id, upload_id);


--
-- Name: CONSTRAINT event_upload_event_id_upload_id_key ON event_upload; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON CONSTRAINT event_upload_event_id_upload_id_key ON vibetype.event_upload IS 'Ensures that each upload is associated with a unique event, preventing duplicate uploads for the same event.';


--
-- Name: event_upload event_upload_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_upload
    ADD CONSTRAINT event_upload_pkey PRIMARY KEY (id);


--
-- Name: friendship friendship_a_account_id_b_account_id_key; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.friendship
    ADD CONSTRAINT friendship_a_account_id_b_account_id_key UNIQUE (a_account_id, b_account_id);


--
-- Name: friendship friendship_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.friendship
    ADD CONSTRAINT friendship_pkey PRIMARY KEY (id);


--
-- Name: guest guest_event_id_contact_id_key; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.guest
    ADD CONSTRAINT guest_event_id_contact_id_key UNIQUE (event_id, contact_id);


--
-- Name: guest guest_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.guest
    ADD CONSTRAINT guest_pkey PRIMARY KEY (id);


--
-- Name: legal_term_acceptance legal_term_acceptance_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.legal_term_acceptance
    ADD CONSTRAINT legal_term_acceptance_pkey PRIMARY KEY (id);


--
-- Name: legal_term legal_term_language_version_key; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.legal_term
    ADD CONSTRAINT legal_term_language_version_key UNIQUE (language, version);


--
-- Name: legal_term legal_term_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.legal_term
    ADD CONSTRAINT legal_term_pkey PRIMARY KEY (id);


--
-- Name: preference_event_category preference_event_category_account_id_category_id_key; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.preference_event_category
    ADD CONSTRAINT preference_event_category_account_id_category_id_key UNIQUE (account_id, category_id);


--
-- Name: preference_event_category preference_event_category_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.preference_event_category
    ADD CONSTRAINT preference_event_category_pkey PRIMARY KEY (id);


--
-- Name: preference_event_format preference_event_format_account_id_format_id_key; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.preference_event_format
    ADD CONSTRAINT preference_event_format_account_id_format_id_key UNIQUE (account_id, format_id);


--
-- Name: preference_event_format preference_event_format_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.preference_event_format
    ADD CONSTRAINT preference_event_format_pkey PRIMARY KEY (id);


--
-- Name: preference_event_location preference_event_location_created_by_location_radius_key; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.preference_event_location
    ADD CONSTRAINT preference_event_location_created_by_location_radius_key UNIQUE (created_by, location, radius);


--
-- Name: preference_event_location preference_event_location_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.preference_event_location
    ADD CONSTRAINT preference_event_location_pkey PRIMARY KEY (id);


--
-- Name: preference_event_size preference_event_size_account_id_event_size_key; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.preference_event_size
    ADD CONSTRAINT preference_event_size_account_id_event_size_key UNIQUE (account_id, event_size);


--
-- Name: preference_event_size preference_event_size_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.preference_event_size
    ADD CONSTRAINT preference_event_size_pkey PRIMARY KEY (id);


--
-- Name: profile_picture profile_picture_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.profile_picture
    ADD CONSTRAINT profile_picture_pkey PRIMARY KEY (id);


--
-- Name: profile_picture profile_picture_unique; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.profile_picture
    ADD CONSTRAINT profile_picture_unique UNIQUE (account_id);


--
-- Name: report report_created_by_target_account_id_target_event_id_target__key; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.report
    ADD CONSTRAINT report_created_by_target_account_id_target_event_id_target__key UNIQUE (created_by, target_account_id, target_event_id, target_upload_id);


--
-- Name: CONSTRAINT report_created_by_target_account_id_target_event_id_target__key ON report; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON CONSTRAINT report_created_by_target_account_id_target_event_id_target__key ON vibetype.report IS 'Ensures that the same user cannot submit multiple reports on the same element (account, event, or upload).';


--
-- Name: report report_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.report
    ADD CONSTRAINT report_pkey PRIMARY KEY (id);


--
-- Name: event_category unique_event_category_name; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_category
    ADD CONSTRAINT unique_event_category_name UNIQUE (name);


--
-- Name: upload upload_pkey; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.upload
    ADD CONSTRAINT upload_pkey PRIMARY KEY (id);


--
-- Name: upload upload_storage_key_key; Type: CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.upload
    ADD CONSTRAINT upload_storage_key_key UNIQUE (storage_key);


--
-- Name: account account_email_address_key; Type: CONSTRAINT; Schema: vibetype_private; Owner: ci
--

ALTER TABLE ONLY vibetype_private.account
    ADD CONSTRAINT account_email_address_key UNIQUE (email_address);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: vibetype_private; Owner: ci
--

ALTER TABLE ONLY vibetype_private.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: achievement_code achievement_code_alias_key; Type: CONSTRAINT; Schema: vibetype_private; Owner: ci
--

ALTER TABLE ONLY vibetype_private.achievement_code
    ADD CONSTRAINT achievement_code_alias_key UNIQUE (alias);


--
-- Name: achievement_code achievement_code_pkey; Type: CONSTRAINT; Schema: vibetype_private; Owner: ci
--

ALTER TABLE ONLY vibetype_private.achievement_code
    ADD CONSTRAINT achievement_code_pkey PRIMARY KEY (id);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: vibetype_private; Owner: ci
--

ALTER TABLE ONLY vibetype_private.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: jwt jwt_pkey; Type: CONSTRAINT; Schema: vibetype_private; Owner: ci
--

ALTER TABLE ONLY vibetype_private.jwt
    ADD CONSTRAINT jwt_pkey PRIMARY KEY (id);


--
-- Name: jwt jwt_token_key; Type: CONSTRAINT; Schema: vibetype_private; Owner: ci
--

ALTER TABLE ONLY vibetype_private.jwt
    ADD CONSTRAINT jwt_token_key UNIQUE (token);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: vibetype_private; Owner: ci
--

ALTER TABLE ONLY vibetype_private.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: idx_account_username_like; Type: INDEX; Schema: vibetype; Owner: ci
--

CREATE INDEX idx_account_username_like ON vibetype.account USING gin (username public.gin_trgm_ops);


--
-- Name: INDEX idx_account_username_like; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON INDEX vibetype.idx_account_username_like IS 'Index useful for trigram matching as in LIKE/ILIKE conditions on username.';


--
-- Name: idx_address_created_by; Type: INDEX; Schema: vibetype; Owner: ci
--

CREATE INDEX idx_address_created_by ON vibetype.address USING btree (created_by);


--
-- Name: INDEX idx_address_created_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON INDEX vibetype.idx_address_created_by IS 'B-Tree index to optimize lookups by creator.';


--
-- Name: idx_address_location; Type: INDEX; Schema: vibetype; Owner: ci
--

CREATE INDEX idx_address_location ON vibetype.address USING gist (location);


--
-- Name: INDEX idx_address_location; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON INDEX vibetype.idx_address_location IS 'GIST index on the location for efficient spatial queries.';


--
-- Name: idx_address_updated_by; Type: INDEX; Schema: vibetype; Owner: ci
--

CREATE INDEX idx_address_updated_by ON vibetype.address USING btree (updated_by);


--
-- Name: INDEX idx_address_updated_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON INDEX vibetype.idx_address_updated_by IS 'B-Tree index to optimize lookups by updater.';


--
-- Name: idx_device_updated_by; Type: INDEX; Schema: vibetype; Owner: ci
--

CREATE INDEX idx_device_updated_by ON vibetype.device USING btree (updated_by);


--
-- Name: INDEX idx_device_updated_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON INDEX vibetype.idx_device_updated_by IS 'B-Tree index to optimize lookups by updater.';


--
-- Name: idx_event_search_vector; Type: INDEX; Schema: vibetype; Owner: ci
--

CREATE INDEX idx_event_search_vector ON vibetype.event USING gin (search_vector);


--
-- Name: INDEX idx_event_search_vector; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON INDEX vibetype.idx_event_search_vector IS 'GIN index on the search vector to improve full-text search performance.';


--
-- Name: idx_event_upload_is_header_image_unique; Type: INDEX; Schema: vibetype; Owner: ci
--

CREATE UNIQUE INDEX idx_event_upload_is_header_image_unique ON vibetype.event_upload USING btree (event_id) WHERE (is_header_image = true);


--
-- Name: INDEX idx_event_upload_is_header_image_unique; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON INDEX vibetype.idx_event_upload_is_header_image_unique IS 'Ensures that at most one header image exists per event.';


--
-- Name: idx_friendship_created_by; Type: INDEX; Schema: vibetype; Owner: ci
--

CREATE INDEX idx_friendship_created_by ON vibetype.friendship USING btree (created_by);


--
-- Name: INDEX idx_friendship_created_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON INDEX vibetype.idx_friendship_created_by IS 'B-Tree index to optimize lookups by creator.';


--
-- Name: idx_friendship_updated_by; Type: INDEX; Schema: vibetype; Owner: ci
--

CREATE INDEX idx_friendship_updated_by ON vibetype.friendship USING btree (updated_by);


--
-- Name: INDEX idx_friendship_updated_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON INDEX vibetype.idx_friendship_updated_by IS 'B-Tree index to optimize lookups by updater.';


--
-- Name: idx_guest_updated_by; Type: INDEX; Schema: vibetype; Owner: ci
--

CREATE INDEX idx_guest_updated_by ON vibetype.guest USING btree (updated_by);


--
-- Name: INDEX idx_guest_updated_by; Type: COMMENT; Schema: vibetype; Owner: ci
--

COMMENT ON INDEX vibetype.idx_guest_updated_by IS 'B-Tree index to optimize lookups by updater.';


--
-- Name: idx_account_private_location; Type: INDEX; Schema: vibetype_private; Owner: ci
--

CREATE INDEX idx_account_private_location ON vibetype_private.account USING gist (location);


--
-- Name: INDEX idx_account_private_location; Type: COMMENT; Schema: vibetype_private; Owner: ci
--

COMMENT ON INDEX vibetype_private.idx_account_private_location IS 'GIST index on the location for efficient spatial queries.';


--
-- Name: guest vibetype_guest_update; Type: TRIGGER; Schema: vibetype; Owner: ci
--

CREATE TRIGGER vibetype_guest_update BEFORE UPDATE ON vibetype.guest FOR EACH ROW EXECUTE FUNCTION vibetype.trigger_guest_update();


--
-- Name: legal_term vibetype_legal_term_delete; Type: TRIGGER; Schema: vibetype; Owner: ci
--

CREATE TRIGGER vibetype_legal_term_delete BEFORE DELETE ON vibetype.legal_term FOR EACH ROW EXECUTE FUNCTION vibetype.legal_term_change();


--
-- Name: legal_term vibetype_legal_term_update; Type: TRIGGER; Schema: vibetype; Owner: ci
--

CREATE TRIGGER vibetype_legal_term_update BEFORE UPDATE ON vibetype.legal_term FOR EACH ROW EXECUTE FUNCTION vibetype.legal_term_change();


--
-- Name: address vibetype_trigger_address_update; Type: TRIGGER; Schema: vibetype; Owner: ci
--

CREATE TRIGGER vibetype_trigger_address_update BEFORE UPDATE ON vibetype.address FOR EACH ROW EXECUTE FUNCTION vibetype.trigger_metadata_update();


--
-- Name: contact vibetype_trigger_contact_update_account_id; Type: TRIGGER; Schema: vibetype; Owner: ci
--

CREATE TRIGGER vibetype_trigger_contact_update_account_id BEFORE UPDATE OF account_id, created_by ON vibetype.contact FOR EACH ROW EXECUTE FUNCTION vibetype.trigger_contact_update_account_id();


--
-- Name: device vibetype_trigger_device_update; Type: TRIGGER; Schema: vibetype; Owner: ci
--

CREATE TRIGGER vibetype_trigger_device_update BEFORE UPDATE ON vibetype.device FOR EACH ROW EXECUTE FUNCTION vibetype.trigger_metadata_update();


--
-- Name: device vibetype_trigger_device_update_fcm; Type: TRIGGER; Schema: vibetype; Owner: ci
--

CREATE TRIGGER vibetype_trigger_device_update_fcm BEFORE UPDATE ON vibetype.device FOR EACH ROW EXECUTE FUNCTION vibetype.trigger_metadata_update_fcm();


--
-- Name: event vibetype_trigger_event_search_vector; Type: TRIGGER; Schema: vibetype; Owner: ci
--

CREATE TRIGGER vibetype_trigger_event_search_vector BEFORE INSERT OR UPDATE OF name, description, language ON vibetype.event FOR EACH ROW EXECUTE FUNCTION vibetype.trigger_event_search_vector();


--
-- Name: friendship vibetype_trigger_friendship_update; Type: TRIGGER; Schema: vibetype; Owner: ci
--

CREATE TRIGGER vibetype_trigger_friendship_update BEFORE UPDATE ON vibetype.friendship FOR EACH ROW EXECUTE FUNCTION vibetype.trigger_metadata_update();


--
-- Name: upload vibetype_trigger_upload_insert; Type: TRIGGER; Schema: vibetype; Owner: ci
--

CREATE TRIGGER vibetype_trigger_upload_insert BEFORE INSERT ON vibetype.upload FOR EACH ROW EXECUTE FUNCTION vibetype.trigger_upload_insert();


--
-- Name: account vibetype_private_account_email_address_verification_valid_until; Type: TRIGGER; Schema: vibetype_private; Owner: ci
--

CREATE TRIGGER vibetype_private_account_email_address_verification_valid_until BEFORE INSERT OR UPDATE OF email_address_verification ON vibetype_private.account FOR EACH ROW EXECUTE FUNCTION vibetype_private.account_email_address_verification_valid_until();


--
-- Name: account vibetype_private_account_password_reset_verification_valid_unti; Type: TRIGGER; Schema: vibetype_private; Owner: ci
--

CREATE TRIGGER vibetype_private_account_password_reset_verification_valid_unti BEFORE INSERT OR UPDATE OF password_reset_verification ON vibetype_private.account FOR EACH ROW EXECUTE FUNCTION vibetype_private.account_password_reset_verification_valid_until();


--
-- Name: changes changes_project_fkey; Type: FK CONSTRAINT; Schema: sqitch; Owner: ci
--

ALTER TABLE ONLY sqitch.changes
    ADD CONSTRAINT changes_project_fkey FOREIGN KEY (project) REFERENCES sqitch.projects(project) ON UPDATE CASCADE;


--
-- Name: dependencies dependencies_change_id_fkey; Type: FK CONSTRAINT; Schema: sqitch; Owner: ci
--

ALTER TABLE ONLY sqitch.dependencies
    ADD CONSTRAINT dependencies_change_id_fkey FOREIGN KEY (change_id) REFERENCES sqitch.changes(change_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: dependencies dependencies_dependency_id_fkey; Type: FK CONSTRAINT; Schema: sqitch; Owner: ci
--

ALTER TABLE ONLY sqitch.dependencies
    ADD CONSTRAINT dependencies_dependency_id_fkey FOREIGN KEY (dependency_id) REFERENCES sqitch.changes(change_id) ON UPDATE CASCADE;


--
-- Name: events events_project_fkey; Type: FK CONSTRAINT; Schema: sqitch; Owner: ci
--

ALTER TABLE ONLY sqitch.events
    ADD CONSTRAINT events_project_fkey FOREIGN KEY (project) REFERENCES sqitch.projects(project) ON UPDATE CASCADE;


--
-- Name: tags tags_change_id_fkey; Type: FK CONSTRAINT; Schema: sqitch; Owner: ci
--

ALTER TABLE ONLY sqitch.tags
    ADD CONSTRAINT tags_change_id_fkey FOREIGN KEY (change_id) REFERENCES sqitch.changes(change_id) ON UPDATE CASCADE;


--
-- Name: tags tags_project_fkey; Type: FK CONSTRAINT; Schema: sqitch; Owner: ci
--

ALTER TABLE ONLY sqitch.tags
    ADD CONSTRAINT tags_project_fkey FOREIGN KEY (project) REFERENCES sqitch.projects(project) ON UPDATE CASCADE;


--
-- Name: account_block account_block_blocked_account_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.account_block
    ADD CONSTRAINT account_block_blocked_account_id_fkey FOREIGN KEY (blocked_account_id) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: account_block account_block_created_by_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.account_block
    ADD CONSTRAINT account_block_created_by_fkey FOREIGN KEY (created_by) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: account account_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.account
    ADD CONSTRAINT account_id_fkey FOREIGN KEY (id) REFERENCES vibetype_private.account(id) ON DELETE CASCADE;


--
-- Name: account_social_network account_social_network_account_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.account_social_network
    ADD CONSTRAINT account_social_network_account_id_fkey FOREIGN KEY (account_id) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: achievement achievement_account_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.achievement
    ADD CONSTRAINT achievement_account_id_fkey FOREIGN KEY (account_id) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: address address_created_by_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.address
    ADD CONSTRAINT address_created_by_fkey FOREIGN KEY (created_by) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: address address_updated_by_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.address
    ADD CONSTRAINT address_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES vibetype.account(id) ON DELETE SET NULL;


--
-- Name: contact contact_account_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.contact
    ADD CONSTRAINT contact_account_id_fkey FOREIGN KEY (account_id) REFERENCES vibetype.account(id) ON DELETE SET NULL;


--
-- Name: contact contact_address_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.contact
    ADD CONSTRAINT contact_address_id_fkey FOREIGN KEY (address_id) REFERENCES vibetype.address(id) ON DELETE SET NULL;


--
-- Name: contact contact_created_by_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.contact
    ADD CONSTRAINT contact_created_by_fkey FOREIGN KEY (created_by) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: device device_created_by_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.device
    ADD CONSTRAINT device_created_by_fkey FOREIGN KEY (created_by) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: device device_updated_by_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.device
    ADD CONSTRAINT device_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES vibetype.account(id) ON DELETE SET NULL;


--
-- Name: event event_address_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event
    ADD CONSTRAINT event_address_id_fkey FOREIGN KEY (address_id) REFERENCES vibetype.address(id) ON DELETE SET NULL;


--
-- Name: event_category_mapping event_category_mapping_category_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_category_mapping
    ADD CONSTRAINT event_category_mapping_category_id_fkey FOREIGN KEY (category_id) REFERENCES vibetype.event_category(id) ON DELETE CASCADE;


--
-- Name: event_category_mapping event_category_mapping_event_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_category_mapping
    ADD CONSTRAINT event_category_mapping_event_id_fkey FOREIGN KEY (event_id) REFERENCES vibetype.event(id) ON DELETE CASCADE;


--
-- Name: event event_created_by_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event
    ADD CONSTRAINT event_created_by_fkey FOREIGN KEY (created_by) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: event_favorite event_favorite_created_by_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_favorite
    ADD CONSTRAINT event_favorite_created_by_fkey FOREIGN KEY (created_by) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: event_favorite event_favorite_event_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_favorite
    ADD CONSTRAINT event_favorite_event_id_fkey FOREIGN KEY (event_id) REFERENCES vibetype.event(id) ON DELETE CASCADE;


--
-- Name: event_format_mapping event_format_mapping_event_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_format_mapping
    ADD CONSTRAINT event_format_mapping_event_id_fkey FOREIGN KEY (event_id) REFERENCES vibetype.event(id) ON DELETE CASCADE;


--
-- Name: event_format_mapping event_format_mapping_format_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_format_mapping
    ADD CONSTRAINT event_format_mapping_format_id_fkey FOREIGN KEY (format_id) REFERENCES vibetype.event_format(id) ON DELETE CASCADE;


--
-- Name: event_recommendation event_recommendation_account_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_recommendation
    ADD CONSTRAINT event_recommendation_account_id_fkey FOREIGN KEY (account_id) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: event_recommendation event_recommendation_event_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_recommendation
    ADD CONSTRAINT event_recommendation_event_id_fkey FOREIGN KEY (event_id) REFERENCES vibetype.event(id) ON DELETE CASCADE;


--
-- Name: event_upload event_upload_event_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_upload
    ADD CONSTRAINT event_upload_event_id_fkey FOREIGN KEY (event_id) REFERENCES vibetype.event(id) ON DELETE CASCADE;


--
-- Name: event_upload event_upload_upload_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.event_upload
    ADD CONSTRAINT event_upload_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES vibetype.upload(id) ON DELETE CASCADE;


--
-- Name: friendship friendship_a_account_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.friendship
    ADD CONSTRAINT friendship_a_account_id_fkey FOREIGN KEY (a_account_id) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: friendship friendship_b_account_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.friendship
    ADD CONSTRAINT friendship_b_account_id_fkey FOREIGN KEY (b_account_id) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: friendship friendship_created_by_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.friendship
    ADD CONSTRAINT friendship_created_by_fkey FOREIGN KEY (created_by) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: friendship friendship_updated_by_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.friendship
    ADD CONSTRAINT friendship_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES vibetype.account(id) ON DELETE SET NULL;


--
-- Name: guest guest_contact_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.guest
    ADD CONSTRAINT guest_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES vibetype.contact(id) ON DELETE CASCADE;


--
-- Name: guest guest_event_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.guest
    ADD CONSTRAINT guest_event_id_fkey FOREIGN KEY (event_id) REFERENCES vibetype.event(id) ON DELETE CASCADE;


--
-- Name: guest guest_updated_by_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.guest
    ADD CONSTRAINT guest_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES vibetype.account(id) ON DELETE SET NULL;


--
-- Name: legal_term_acceptance legal_term_acceptance_account_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.legal_term_acceptance
    ADD CONSTRAINT legal_term_acceptance_account_id_fkey FOREIGN KEY (account_id) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: legal_term_acceptance legal_term_acceptance_legal_term_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.legal_term_acceptance
    ADD CONSTRAINT legal_term_acceptance_legal_term_id_fkey FOREIGN KEY (legal_term_id) REFERENCES vibetype.legal_term(id) ON DELETE RESTRICT;


--
-- Name: preference_event_category preference_event_category_account_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.preference_event_category
    ADD CONSTRAINT preference_event_category_account_id_fkey FOREIGN KEY (account_id) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: preference_event_category preference_event_category_category_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.preference_event_category
    ADD CONSTRAINT preference_event_category_category_id_fkey FOREIGN KEY (category_id) REFERENCES vibetype.event_category(id) ON DELETE CASCADE;


--
-- Name: preference_event_format preference_event_format_account_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.preference_event_format
    ADD CONSTRAINT preference_event_format_account_id_fkey FOREIGN KEY (account_id) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: preference_event_format preference_event_format_format_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.preference_event_format
    ADD CONSTRAINT preference_event_format_format_id_fkey FOREIGN KEY (format_id) REFERENCES vibetype.event_format(id) ON DELETE CASCADE;


--
-- Name: preference_event_location preference_event_location_created_by_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.preference_event_location
    ADD CONSTRAINT preference_event_location_created_by_fkey FOREIGN KEY (created_by) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: preference_event_size preference_event_size_account_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.preference_event_size
    ADD CONSTRAINT preference_event_size_account_id_fkey FOREIGN KEY (account_id) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: profile_picture profile_picture_account_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.profile_picture
    ADD CONSTRAINT profile_picture_account_id_fkey FOREIGN KEY (account_id) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: profile_picture profile_picture_upload_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.profile_picture
    ADD CONSTRAINT profile_picture_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES vibetype.upload(id) ON DELETE CASCADE;


--
-- Name: report report_created_by_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.report
    ADD CONSTRAINT report_created_by_fkey FOREIGN KEY (created_by) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: report report_target_account_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.report
    ADD CONSTRAINT report_target_account_id_fkey FOREIGN KEY (target_account_id) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: report report_target_event_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.report
    ADD CONSTRAINT report_target_event_id_fkey FOREIGN KEY (target_event_id) REFERENCES vibetype.event(id) ON DELETE CASCADE;


--
-- Name: report report_target_upload_id_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.report
    ADD CONSTRAINT report_target_upload_id_fkey FOREIGN KEY (target_upload_id) REFERENCES vibetype.upload(id) ON DELETE CASCADE;


--
-- Name: upload upload_created_by_fkey; Type: FK CONSTRAINT; Schema: vibetype; Owner: ci
--

ALTER TABLE ONLY vibetype.upload
    ADD CONSTRAINT upload_created_by_fkey FOREIGN KEY (created_by) REFERENCES vibetype.account(id) ON DELETE CASCADE;


--
-- Name: account; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.account ENABLE ROW LEVEL SECURITY;

--
-- Name: account_block; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.account_block ENABLE ROW LEVEL SECURITY;

--
-- Name: account_block account_block_all; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY account_block_all ON vibetype.account_block USING ((created_by = vibetype.invoker_account_id()));


--
-- Name: account account_select; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY account_select ON vibetype.account FOR SELECT USING (true);


--
-- Name: account_social_network; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.account_social_network ENABLE ROW LEVEL SECURITY;

--
-- Name: account_social_network account_social_network_all; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY account_social_network_all ON vibetype.account_social_network USING ((account_id = vibetype.invoker_account_id()));


--
-- Name: account_social_network account_social_network_select; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY account_social_network_select ON vibetype.account_social_network FOR SELECT USING (true);


--
-- Name: account account_update; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY account_update ON vibetype.account FOR UPDATE USING ((id = vibetype.invoker_account_id()));


--
-- Name: achievement; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.achievement ENABLE ROW LEVEL SECURITY;

--
-- Name: achievement achievement_select; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY achievement_select ON vibetype.achievement FOR SELECT USING (true);


--
-- Name: address; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.address ENABLE ROW LEVEL SECURITY;

--
-- Name: address address_all; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY address_all ON vibetype.address USING ((((created_by = vibetype.invoker_account_id()) OR (id IN ( SELECT event_policy_select.address_id
   FROM vibetype_private.event_policy_select() event_policy_select(id, address_id, description, "end", guest_count_maximum, is_archived, is_in_person, is_remote, language, name, slug, start, url, visibility, created_at, created_by, search_vector)))) AND (NOT (created_by IN ( SELECT account_block_ids.id
   FROM vibetype_private.account_block_ids() account_block_ids(id)))))) WITH CHECK ((created_by = vibetype.invoker_account_id()));


--
-- Name: contact; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.contact ENABLE ROW LEVEL SECURITY;

--
-- Name: contact contact_delete; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY contact_delete ON vibetype.contact FOR DELETE USING (((vibetype.invoker_account_id() IS NOT NULL) AND (created_by = vibetype.invoker_account_id()) AND (account_id IS DISTINCT FROM vibetype.invoker_account_id())));


--
-- Name: contact contact_insert; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY contact_insert ON vibetype.contact FOR INSERT WITH CHECK (((created_by = vibetype.invoker_account_id()) AND (NOT (account_id IN ( SELECT account_block.blocked_account_id
   FROM vibetype.account_block
  WHERE (account_block.created_by = vibetype.invoker_account_id()))))));


--
-- Name: contact contact_select; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY contact_select ON vibetype.contact FOR SELECT USING ((((account_id = vibetype.invoker_account_id()) AND (NOT (created_by IN ( SELECT account_block_ids.id
   FROM vibetype_private.account_block_ids() account_block_ids(id))))) OR ((created_by = vibetype.invoker_account_id()) AND ((account_id IS NULL) OR (NOT (account_id IN ( SELECT account_block_ids.id
   FROM vibetype_private.account_block_ids() account_block_ids(id)))))) OR (id IN ( SELECT vibetype.guest_contact_ids() AS guest_contact_ids))));


--
-- Name: contact contact_update; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY contact_update ON vibetype.contact FOR UPDATE USING (((created_by = vibetype.invoker_account_id()) AND (NOT (account_id IN ( SELECT account_block.blocked_account_id
   FROM vibetype.account_block
  WHERE (account_block.created_by = vibetype.invoker_account_id()))))));


--
-- Name: device; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.device ENABLE ROW LEVEL SECURITY;

--
-- Name: device device_all; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY device_all ON vibetype.device USING ((created_by = vibetype.invoker_account_id()));


--
-- Name: event; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.event ENABLE ROW LEVEL SECURITY;

--
-- Name: event event_all; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY event_all ON vibetype.event USING ((created_by = vibetype.invoker_account_id()));


--
-- Name: event_category_mapping; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.event_category_mapping ENABLE ROW LEVEL SECURITY;

--
-- Name: event_category_mapping event_category_mapping_delete; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY event_category_mapping_delete ON vibetype.event_category_mapping FOR DELETE USING ((( SELECT event.created_by
   FROM vibetype.event
  WHERE (event.id = event_category_mapping.event_id)) = vibetype.invoker_account_id()));


--
-- Name: event_category_mapping event_category_mapping_insert; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY event_category_mapping_insert ON vibetype.event_category_mapping FOR INSERT WITH CHECK ((( SELECT event.created_by
   FROM vibetype.event
  WHERE (event.id = event_category_mapping.event_id)) = vibetype.invoker_account_id()));


--
-- Name: event_category_mapping event_category_mapping_select; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY event_category_mapping_select ON vibetype.event_category_mapping FOR SELECT USING ((event_id IN ( SELECT event.id
   FROM vibetype.event)));


--
-- Name: event_favorite; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.event_favorite ENABLE ROW LEVEL SECURITY;

--
-- Name: event_favorite event_favorite_all; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY event_favorite_all ON vibetype.event_favorite USING ((created_by = vibetype.invoker_account_id()));


--
-- Name: event_format_mapping; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.event_format_mapping ENABLE ROW LEVEL SECURITY;

--
-- Name: event_format_mapping event_format_mapping_delete; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY event_format_mapping_delete ON vibetype.event_format_mapping FOR DELETE USING ((( SELECT event.created_by
   FROM vibetype.event
  WHERE (event.id = event_format_mapping.event_id)) = vibetype.invoker_account_id()));


--
-- Name: event_format_mapping event_format_mapping_insert; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY event_format_mapping_insert ON vibetype.event_format_mapping FOR INSERT WITH CHECK ((( SELECT event.created_by
   FROM vibetype.event
  WHERE (event.id = event_format_mapping.event_id)) = vibetype.invoker_account_id()));


--
-- Name: event_format_mapping event_format_mapping_select; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY event_format_mapping_select ON vibetype.event_format_mapping FOR SELECT USING ((event_id IN ( SELECT event.id
   FROM vibetype.event)));


--
-- Name: event_recommendation; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.event_recommendation ENABLE ROW LEVEL SECURITY;

--
-- Name: event_recommendation event_recommendation_select; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY event_recommendation_select ON vibetype.event_recommendation FOR SELECT USING ((account_id = vibetype.invoker_account_id()));


--
-- Name: event event_select; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY event_select ON vibetype.event FOR SELECT USING ((id IN ( SELECT event_policy_select.id
   FROM vibetype_private.event_policy_select() event_policy_select(id, address_id, description, "end", guest_count_maximum, is_archived, is_in_person, is_remote, language, name, slug, start, url, visibility, created_at, created_by, search_vector))));


--
-- Name: event_upload; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.event_upload ENABLE ROW LEVEL SECURITY;

--
-- Name: event_upload event_upload_delete; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY event_upload_delete ON vibetype.event_upload FOR DELETE USING ((event_id IN ( SELECT event.id
   FROM vibetype.event
  WHERE (event.created_by = vibetype.invoker_account_id()))));


--
-- Name: event_upload event_upload_insert; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY event_upload_insert ON vibetype.event_upload FOR INSERT WITH CHECK (((event_id IN ( SELECT event.id
   FROM vibetype.event
  WHERE (event.created_by = vibetype.invoker_account_id()))) AND (upload_id IN ( SELECT upload.id
   FROM vibetype.upload
  WHERE (upload.created_by = vibetype.invoker_account_id())))));


--
-- Name: event_upload event_upload_select; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY event_upload_select ON vibetype.event_upload FOR SELECT USING ((event_id IN ( SELECT event.id
   FROM vibetype.event)));


--
-- Name: friendship; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.friendship ENABLE ROW LEVEL SECURITY;

--
-- Name: friendship friendship_existing; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY friendship_existing ON vibetype.friendship USING ((((vibetype.invoker_account_id() = a_account_id) AND (NOT (b_account_id IN ( SELECT account_block_ids.id
   FROM vibetype_private.account_block_ids() account_block_ids(id))))) OR ((vibetype.invoker_account_id() = b_account_id) AND (NOT (a_account_id IN ( SELECT account_block_ids.id
   FROM vibetype_private.account_block_ids() account_block_ids(id))))))) WITH CHECK (false);


--
-- Name: friendship friendship_insert; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY friendship_insert ON vibetype.friendship FOR INSERT WITH CHECK ((created_by = vibetype.invoker_account_id()));


--
-- Name: friendship friendship_update; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY friendship_update ON vibetype.friendship FOR UPDATE USING ((status = 'requested'::vibetype.friendship_status)) WITH CHECK (((status = 'accepted'::vibetype.friendship_status) AND (updated_by = vibetype.invoker_account_id())));


--
-- Name: guest; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.guest ENABLE ROW LEVEL SECURITY;

--
-- Name: guest guest_delete; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY guest_delete ON vibetype.guest FOR DELETE USING ((event_id IN ( SELECT vibetype.events_organized() AS events_organized)));


--
-- Name: guest guest_insert; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY guest_insert ON vibetype.guest FOR INSERT WITH CHECK (((event_id IN ( SELECT vibetype.events_organized() AS events_organized)) AND ((vibetype.event_guest_count_maximum(event_id) IS NULL) OR (vibetype.event_guest_count_maximum(event_id) > vibetype.guest_count(event_id))) AND (contact_id IN ( SELECT contact.id
   FROM vibetype.contact
  WHERE (contact.created_by = vibetype.invoker_account_id())
EXCEPT
 SELECT c.id
   FROM (vibetype.contact c
     JOIN vibetype.account_block b ON (((c.account_id = b.blocked_account_id) AND (c.created_by = b.created_by))))
  WHERE (c.created_by = vibetype.invoker_account_id())))));


--
-- Name: guest guest_select; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY guest_select ON vibetype.guest FOR SELECT USING (((id = ANY (vibetype.guest_claim_array())) OR (contact_id IN ( SELECT contact.id
   FROM vibetype.contact
  WHERE ((contact.account_id = vibetype.invoker_account_id()) AND (NOT (contact.created_by IN ( SELECT account_block_ids.id
           FROM vibetype_private.account_block_ids() account_block_ids(id))))))) OR ((event_id IN ( SELECT vibetype.events_organized() AS events_organized)) AND (contact_id IN ( SELECT c.id
   FROM vibetype.contact c
  WHERE (((c.account_id IS NULL) OR (NOT (c.account_id IN ( SELECT account_block_ids.id
           FROM vibetype_private.account_block_ids() account_block_ids(id))))) AND (NOT (c.created_by IN ( SELECT account_block_ids.id
           FROM vibetype_private.account_block_ids() account_block_ids(id))))))))));


--
-- Name: guest guest_update; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY guest_update ON vibetype.guest FOR UPDATE USING (((id = ANY (vibetype.guest_claim_array())) OR (contact_id IN ( SELECT contact.id
   FROM vibetype.contact
  WHERE (contact.account_id = vibetype.invoker_account_id())
EXCEPT
 SELECT c.id
   FROM (vibetype.contact c
     JOIN vibetype.account_block b ON (((c.account_id = b.created_by) AND (c.created_by = b.blocked_account_id))))
  WHERE (c.account_id = vibetype.invoker_account_id()))) OR ((event_id IN ( SELECT vibetype.events_organized() AS events_organized)) AND (contact_id IN ( SELECT c.id
   FROM vibetype.contact c
  WHERE ((NOT (c.created_by IN ( SELECT account_block_ids.id
           FROM vibetype_private.account_block_ids() account_block_ids(id)))) AND ((c.account_id IS NULL) OR (NOT (c.account_id IN ( SELECT account_block_ids.id
           FROM vibetype_private.account_block_ids() account_block_ids(id)))))))))));


--
-- Name: legal_term; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.legal_term ENABLE ROW LEVEL SECURITY;

--
-- Name: legal_term_acceptance; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.legal_term_acceptance ENABLE ROW LEVEL SECURITY;

--
-- Name: legal_term_acceptance legal_term_acceptance_all; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY legal_term_acceptance_all ON vibetype.legal_term_acceptance USING ((account_id = vibetype.invoker_account_id()));


--
-- Name: legal_term legal_term_select; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY legal_term_select ON vibetype.legal_term FOR SELECT USING (true);


--
-- Name: preference_event_category; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.preference_event_category ENABLE ROW LEVEL SECURITY;

--
-- Name: preference_event_category preference_event_category_all; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY preference_event_category_all ON vibetype.preference_event_category USING ((account_id = vibetype.invoker_account_id()));


--
-- Name: preference_event_format; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.preference_event_format ENABLE ROW LEVEL SECURITY;

--
-- Name: preference_event_format preference_event_format_all; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY preference_event_format_all ON vibetype.preference_event_format USING ((account_id = vibetype.invoker_account_id()));


--
-- Name: preference_event_location; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.preference_event_location ENABLE ROW LEVEL SECURITY;

--
-- Name: preference_event_location preference_event_location_all; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY preference_event_location_all ON vibetype.preference_event_location USING ((created_by = vibetype.invoker_account_id()));


--
-- Name: preference_event_size; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.preference_event_size ENABLE ROW LEVEL SECURITY;

--
-- Name: preference_event_size preference_event_size_all; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY preference_event_size_all ON vibetype.preference_event_size USING ((account_id = vibetype.invoker_account_id()));


--
-- Name: profile_picture; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.profile_picture ENABLE ROW LEVEL SECURITY;

--
-- Name: profile_picture profile_picture_all; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY profile_picture_all ON vibetype.profile_picture USING ((account_id = vibetype.invoker_account_id()));


--
-- Name: profile_picture profile_picture_delete_service; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY profile_picture_delete_service ON vibetype.profile_picture FOR DELETE TO vibetype USING (true);


--
-- Name: profile_picture profile_picture_select; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY profile_picture_select ON vibetype.profile_picture FOR SELECT USING (true);


--
-- Name: report; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.report ENABLE ROW LEVEL SECURITY;

--
-- Name: report report_all; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY report_all ON vibetype.report USING ((created_by = vibetype.invoker_account_id()));


--
-- Name: upload; Type: ROW SECURITY; Schema: vibetype; Owner: ci
--

ALTER TABLE vibetype.upload ENABLE ROW LEVEL SECURITY;

--
-- Name: upload upload_delete; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY upload_delete ON vibetype.upload FOR DELETE USING ((created_by = vibetype.invoker_account_id()));


--
-- Name: upload upload_insert; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY upload_insert ON vibetype.upload FOR INSERT WITH CHECK ((created_by = vibetype.invoker_account_id()));


--
-- Name: upload upload_select; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY upload_select ON vibetype.upload FOR SELECT USING (((created_by = vibetype.invoker_account_id()) OR (id IN ( SELECT profile_picture.upload_id
   FROM vibetype.profile_picture))));


--
-- Name: upload upload_service_vibetype_all; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY upload_service_vibetype_all ON vibetype.upload TO vibetype USING (true);


--
-- Name: upload upload_update; Type: POLICY; Schema: vibetype; Owner: ci
--

CREATE POLICY upload_update ON vibetype.upload FOR UPDATE USING ((created_by = vibetype.invoker_account_id()));


--
-- Name: achievement_code; Type: ROW SECURITY; Schema: vibetype_private; Owner: ci
--

ALTER TABLE vibetype_private.achievement_code ENABLE ROW LEVEL SECURITY;

--
-- Name: achievement_code achievement_code_select; Type: POLICY; Schema: vibetype_private; Owner: ci
--

CREATE POLICY achievement_code_select ON vibetype_private.achievement_code FOR SELECT USING (true);


--
-- Name: SCHEMA vibetype; Type: ACL; Schema: -; Owner: ci
--

GRANT USAGE ON SCHEMA vibetype TO vibetype_anonymous;
GRANT USAGE ON SCHEMA vibetype TO vibetype_account;
GRANT USAGE ON SCHEMA vibetype TO vibetype;


--
-- Name: SCHEMA vibetype_private; Type: ACL; Schema: -; Owner: ci
--

GRANT USAGE ON SCHEMA vibetype_private TO grafana;


--
-- Name: FUNCTION gtrgm_in(cstring); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.gtrgm_in(cstring) FROM PUBLIC;


--
-- Name: FUNCTION gtrgm_out(public.gtrgm); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.gtrgm_out(public.gtrgm) FROM PUBLIC;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.armor(bytea) FROM PUBLIC;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.armor(bytea, text[], text[]) FROM PUBLIC;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.crypt(text, text) FROM PUBLIC;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.dearmor(text) FROM PUBLIC;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.decrypt(bytea, bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.digest(bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.digest(text, text) FROM PUBLIC;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.encrypt(bytea, bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.gen_random_bytes(integer) FROM PUBLIC;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.gen_random_uuid() FROM PUBLIC;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.gen_salt(text) FROM PUBLIC;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.gen_salt(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION gin_extract_query_trgm(text, internal, smallint, internal, internal, internal, internal); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.gin_extract_query_trgm(text, internal, smallint, internal, internal, internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION gin_extract_value_trgm(text, internal); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.gin_extract_value_trgm(text, internal) FROM PUBLIC;


--
-- Name: FUNCTION gin_trgm_consistent(internal, smallint, text, integer, internal, internal, internal, internal); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.gin_trgm_consistent(internal, smallint, text, integer, internal, internal, internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION gin_trgm_triconsistent(internal, smallint, text, integer, internal, internal, internal); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.gin_trgm_triconsistent(internal, smallint, text, integer, internal, internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION gtrgm_compress(internal); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.gtrgm_compress(internal) FROM PUBLIC;


--
-- Name: FUNCTION gtrgm_consistent(internal, text, smallint, oid, internal); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.gtrgm_consistent(internal, text, smallint, oid, internal) FROM PUBLIC;


--
-- Name: FUNCTION gtrgm_decompress(internal); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.gtrgm_decompress(internal) FROM PUBLIC;


--
-- Name: FUNCTION gtrgm_distance(internal, text, smallint, oid, internal); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.gtrgm_distance(internal, text, smallint, oid, internal) FROM PUBLIC;


--
-- Name: FUNCTION gtrgm_options(internal); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.gtrgm_options(internal) FROM PUBLIC;


--
-- Name: FUNCTION gtrgm_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.gtrgm_penalty(internal, internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION gtrgm_picksplit(internal, internal); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.gtrgm_picksplit(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION gtrgm_same(public.gtrgm, public.gtrgm, internal); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.gtrgm_same(public.gtrgm, public.gtrgm, internal) FROM PUBLIC;


--
-- Name: FUNCTION gtrgm_union(internal, internal); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.gtrgm_union(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.hmac(bytea, bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.hmac(text, text, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_armor_headers(text, OUT key text, OUT value text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_key_id(bytea) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_pub_encrypt(text, bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_sym_decrypt(bytea, text, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_sym_encrypt(text, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_sym_encrypt(text, text, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) FROM PUBLIC;


--
-- Name: FUNCTION set_limit(real); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.set_limit(real) FROM PUBLIC;


--
-- Name: FUNCTION show_limit(); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.show_limit() FROM PUBLIC;


--
-- Name: FUNCTION show_trgm(text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.show_trgm(text) FROM PUBLIC;


--
-- Name: FUNCTION similarity(text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.similarity(text, text) FROM PUBLIC;


--
-- Name: FUNCTION similarity_dist(text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.similarity_dist(text, text) FROM PUBLIC;


--
-- Name: FUNCTION similarity_op(text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.similarity_op(text, text) FROM PUBLIC;


--
-- Name: FUNCTION strict_word_similarity(text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.strict_word_similarity(text, text) FROM PUBLIC;


--
-- Name: FUNCTION strict_word_similarity_commutator_op(text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.strict_word_similarity_commutator_op(text, text) FROM PUBLIC;


--
-- Name: FUNCTION strict_word_similarity_dist_commutator_op(text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.strict_word_similarity_dist_commutator_op(text, text) FROM PUBLIC;


--
-- Name: FUNCTION strict_word_similarity_dist_op(text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.strict_word_similarity_dist_op(text, text) FROM PUBLIC;


--
-- Name: FUNCTION strict_word_similarity_op(text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.strict_word_similarity_op(text, text) FROM PUBLIC;


--
-- Name: FUNCTION word_similarity(text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.word_similarity(text, text) FROM PUBLIC;


--
-- Name: FUNCTION word_similarity_commutator_op(text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.word_similarity_commutator_op(text, text) FROM PUBLIC;


--
-- Name: FUNCTION word_similarity_dist_commutator_op(text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.word_similarity_dist_commutator_op(text, text) FROM PUBLIC;


--
-- Name: FUNCTION word_similarity_dist_op(text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.word_similarity_dist_op(text, text) FROM PUBLIC;


--
-- Name: FUNCTION word_similarity_op(text, text); Type: ACL; Schema: public; Owner: ci
--

REVOKE ALL ON FUNCTION public.word_similarity_op(text, text) FROM PUBLIC;


--
-- Name: FUNCTION account_delete(password text); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.account_delete(password text) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.account_delete(password text) TO vibetype_account;


--
-- Name: FUNCTION account_email_address_verification(code uuid); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.account_email_address_verification(code uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.account_email_address_verification(code uuid) TO vibetype_account;
GRANT ALL ON FUNCTION vibetype.account_email_address_verification(code uuid) TO vibetype_anonymous;


--
-- Name: FUNCTION account_location_update(latitude double precision, longitude double precision); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.account_location_update(latitude double precision, longitude double precision) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.account_location_update(latitude double precision, longitude double precision) TO vibetype_account;


--
-- Name: FUNCTION account_password_change(password_current text, password_new text); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.account_password_change(password_current text, password_new text) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.account_password_change(password_current text, password_new text) TO vibetype_account;


--
-- Name: FUNCTION account_password_reset(code uuid, password text); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.account_password_reset(code uuid, password text) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.account_password_reset(code uuid, password text) TO vibetype_anonymous;
GRANT ALL ON FUNCTION vibetype.account_password_reset(code uuid, password text) TO vibetype_account;


--
-- Name: FUNCTION account_password_reset_request(email_address text, language text); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.account_password_reset_request(email_address text, language text) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.account_password_reset_request(email_address text, language text) TO vibetype_anonymous;
GRANT ALL ON FUNCTION vibetype.account_password_reset_request(email_address text, language text) TO vibetype_account;


--
-- Name: FUNCTION account_registration(birth_date date, email_address text, language text, legal_term_id uuid, password text, username text); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.account_registration(birth_date date, email_address text, language text, legal_term_id uuid, password text, username text) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.account_registration(birth_date date, email_address text, language text, legal_term_id uuid, password text, username text) TO vibetype_anonymous;
GRANT ALL ON FUNCTION vibetype.account_registration(birth_date date, email_address text, language text, legal_term_id uuid, password text, username text) TO vibetype_account;


--
-- Name: FUNCTION account_registration_refresh(account_id uuid, language text); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.account_registration_refresh(account_id uuid, language text) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.account_registration_refresh(account_id uuid, language text) TO vibetype_anonymous;


--
-- Name: TABLE account; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT,UPDATE ON TABLE vibetype.account TO vibetype_account;
GRANT SELECT ON TABLE vibetype.account TO vibetype_anonymous;


--
-- Name: FUNCTION account_search(search_string text); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.account_search(search_string text) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.account_search(search_string text) TO vibetype_account;


--
-- Name: FUNCTION account_upload_quota_bytes(); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.account_upload_quota_bytes() FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.account_upload_quota_bytes() TO vibetype_account;


--
-- Name: FUNCTION achievement_unlock(code uuid, alias text); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.achievement_unlock(code uuid, alias text) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.achievement_unlock(code uuid, alias text) TO vibetype_account;


--
-- Name: FUNCTION authenticate(username text, password text); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.authenticate(username text, password text) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.authenticate(username text, password text) TO vibetype_account;
GRANT ALL ON FUNCTION vibetype.authenticate(username text, password text) TO vibetype_anonymous;


--
-- Name: TABLE guest; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE vibetype.guest TO vibetype_account;
GRANT SELECT,UPDATE ON TABLE vibetype.guest TO vibetype_anonymous;


--
-- Name: FUNCTION create_guests(event_id uuid, contact_ids uuid[]); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.create_guests(event_id uuid, contact_ids uuid[]) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.create_guests(event_id uuid, contact_ids uuid[]) TO vibetype_account;


--
-- Name: TABLE event; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT ON TABLE vibetype.event TO vibetype_anonymous;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE vibetype.event TO vibetype_account;


--
-- Name: FUNCTION event_delete(id uuid, password text); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.event_delete(id uuid, password text) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.event_delete(id uuid, password text) TO vibetype_account;


--
-- Name: FUNCTION event_guest_count_maximum(event_id uuid); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.event_guest_count_maximum(event_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.event_guest_count_maximum(event_id uuid) TO vibetype_account;
GRANT ALL ON FUNCTION vibetype.event_guest_count_maximum(event_id uuid) TO vibetype_anonymous;


--
-- Name: FUNCTION event_search(query text, language vibetype.language); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.event_search(query text, language vibetype.language) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.event_search(query text, language vibetype.language) TO vibetype_account;
GRANT ALL ON FUNCTION vibetype.event_search(query text, language vibetype.language) TO vibetype_anonymous;


--
-- Name: FUNCTION event_unlock(guest_id uuid); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.event_unlock(guest_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.event_unlock(guest_id uuid) TO vibetype_account;
GRANT ALL ON FUNCTION vibetype.event_unlock(guest_id uuid) TO vibetype_anonymous;


--
-- Name: FUNCTION events_organized(); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.events_organized() FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.events_organized() TO vibetype_account;
GRANT ALL ON FUNCTION vibetype.events_organized() TO vibetype_anonymous;


--
-- Name: FUNCTION guest_claim_array(); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.guest_claim_array() FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.guest_claim_array() TO vibetype_account;
GRANT ALL ON FUNCTION vibetype.guest_claim_array() TO vibetype_anonymous;


--
-- Name: FUNCTION guest_contact_ids(); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.guest_contact_ids() FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.guest_contact_ids() TO vibetype_account;
GRANT ALL ON FUNCTION vibetype.guest_contact_ids() TO vibetype_anonymous;


--
-- Name: FUNCTION guest_count(event_id uuid); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.guest_count(event_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.guest_count(event_id uuid) TO vibetype_account;
GRANT ALL ON FUNCTION vibetype.guest_count(event_id uuid) TO vibetype_anonymous;


--
-- Name: FUNCTION invite(guest_id uuid, language text); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.invite(guest_id uuid, language text) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.invite(guest_id uuid, language text) TO vibetype_account;


--
-- Name: FUNCTION invoker_account_id(); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.invoker_account_id() FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.invoker_account_id() TO vibetype_account;
GRANT ALL ON FUNCTION vibetype.invoker_account_id() TO vibetype_anonymous;
GRANT ALL ON FUNCTION vibetype.invoker_account_id() TO vibetype;


--
-- Name: FUNCTION jwt_refresh(jwt_id uuid); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.jwt_refresh(jwt_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.jwt_refresh(jwt_id uuid) TO vibetype_account;
GRANT ALL ON FUNCTION vibetype.jwt_refresh(jwt_id uuid) TO vibetype_anonymous;


--
-- Name: FUNCTION language_iso_full_text_search(language vibetype.language); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.language_iso_full_text_search(language vibetype.language) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.language_iso_full_text_search(language vibetype.language) TO vibetype_anonymous;
GRANT ALL ON FUNCTION vibetype.language_iso_full_text_search(language vibetype.language) TO vibetype_account;


--
-- Name: FUNCTION legal_term_change(); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.legal_term_change() FROM PUBLIC;


--
-- Name: FUNCTION notification_acknowledge(id uuid, is_acknowledged boolean); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.notification_acknowledge(id uuid, is_acknowledged boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.notification_acknowledge(id uuid, is_acknowledged boolean) TO vibetype_anonymous;


--
-- Name: FUNCTION profile_picture_set(upload_id uuid); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.profile_picture_set(upload_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.profile_picture_set(upload_id uuid) TO vibetype_account;


--
-- Name: FUNCTION trigger_contact_update_account_id(); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.trigger_contact_update_account_id() FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.trigger_contact_update_account_id() TO vibetype_account;


--
-- Name: FUNCTION trigger_event_search_vector(); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.trigger_event_search_vector() FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.trigger_event_search_vector() TO vibetype_account;
GRANT ALL ON FUNCTION vibetype.trigger_event_search_vector() TO vibetype_anonymous;


--
-- Name: FUNCTION trigger_guest_update(); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.trigger_guest_update() FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.trigger_guest_update() TO vibetype_account;
GRANT ALL ON FUNCTION vibetype.trigger_guest_update() TO vibetype_anonymous;


--
-- Name: FUNCTION trigger_metadata_update(); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.trigger_metadata_update() FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype.trigger_metadata_update() TO vibetype_account;


--
-- Name: FUNCTION trigger_metadata_update_fcm(); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.trigger_metadata_update_fcm() FROM PUBLIC;


--
-- Name: FUNCTION trigger_upload_insert(); Type: ACL; Schema: vibetype; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype.trigger_upload_insert() FROM PUBLIC;


--
-- Name: FUNCTION account_block_ids(); Type: ACL; Schema: vibetype_private; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype_private.account_block_ids() FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype_private.account_block_ids() TO vibetype_account;
GRANT ALL ON FUNCTION vibetype_private.account_block_ids() TO vibetype_anonymous;


--
-- Name: FUNCTION account_email_address_verification_valid_until(); Type: ACL; Schema: vibetype_private; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype_private.account_email_address_verification_valid_until() FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype_private.account_email_address_verification_valid_until() TO vibetype_account;


--
-- Name: FUNCTION account_password_reset_verification_valid_until(); Type: ACL; Schema: vibetype_private; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype_private.account_password_reset_verification_valid_until() FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype_private.account_password_reset_verification_valid_until() TO vibetype_account;


--
-- Name: FUNCTION adjust_audit_log_id_seq(); Type: ACL; Schema: vibetype_private; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype_private.adjust_audit_log_id_seq() FROM PUBLIC;


--
-- Name: FUNCTION event_policy_select(); Type: ACL; Schema: vibetype_private; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype_private.event_policy_select() FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype_private.event_policy_select() TO vibetype_account;
GRANT ALL ON FUNCTION vibetype_private.event_policy_select() TO vibetype_anonymous;


--
-- Name: FUNCTION events_invited(); Type: ACL; Schema: vibetype_private; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype_private.events_invited() FROM PUBLIC;
GRANT ALL ON FUNCTION vibetype_private.events_invited() TO vibetype_account;
GRANT ALL ON FUNCTION vibetype_private.events_invited() TO vibetype_anonymous;


--
-- Name: FUNCTION trigger_audit_log(); Type: ACL; Schema: vibetype_private; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype_private.trigger_audit_log() FROM PUBLIC;


--
-- Name: FUNCTION trigger_audit_log_create(schema_name text, table_name text); Type: ACL; Schema: vibetype_private; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype_private.trigger_audit_log_create(schema_name text, table_name text) FROM PUBLIC;


--
-- Name: FUNCTION trigger_audit_log_create_multiple(); Type: ACL; Schema: vibetype_private; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype_private.trigger_audit_log_create_multiple() FROM PUBLIC;


--
-- Name: FUNCTION trigger_audit_log_disable(schema_name text, table_name text); Type: ACL; Schema: vibetype_private; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype_private.trigger_audit_log_disable(schema_name text, table_name text) FROM PUBLIC;


--
-- Name: FUNCTION trigger_audit_log_disable_multiple(); Type: ACL; Schema: vibetype_private; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype_private.trigger_audit_log_disable_multiple() FROM PUBLIC;


--
-- Name: FUNCTION trigger_audit_log_drop(schema_name text, table_name text); Type: ACL; Schema: vibetype_private; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype_private.trigger_audit_log_drop(schema_name text, table_name text) FROM PUBLIC;


--
-- Name: FUNCTION trigger_audit_log_drop_multiple(); Type: ACL; Schema: vibetype_private; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype_private.trigger_audit_log_drop_multiple() FROM PUBLIC;


--
-- Name: FUNCTION trigger_audit_log_enable(schema_name text, table_name text); Type: ACL; Schema: vibetype_private; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype_private.trigger_audit_log_enable(schema_name text, table_name text) FROM PUBLIC;


--
-- Name: FUNCTION trigger_audit_log_enable_multiple(); Type: ACL; Schema: vibetype_private; Owner: ci
--

REVOKE ALL ON FUNCTION vibetype_private.trigger_audit_log_enable_multiple() FROM PUBLIC;


--
-- Name: TABLE account_block; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT,INSERT ON TABLE vibetype.account_block TO vibetype_account;
GRANT SELECT ON TABLE vibetype.account_block TO vibetype_anonymous;


--
-- Name: TABLE account_social_network; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT ON TABLE vibetype.account_social_network TO vibetype_anonymous;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE vibetype.account_social_network TO vibetype_account;


--
-- Name: TABLE achievement; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT ON TABLE vibetype.achievement TO vibetype_account;
GRANT SELECT ON TABLE vibetype.achievement TO vibetype_anonymous;


--
-- Name: TABLE address; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT ON TABLE vibetype.address TO vibetype_anonymous;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE vibetype.address TO vibetype_account;


--
-- Name: TABLE contact; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT ON TABLE vibetype.contact TO vibetype_anonymous;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE vibetype.contact TO vibetype_account;


--
-- Name: TABLE device; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE vibetype.device TO vibetype_account;


--
-- Name: TABLE event_category; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT ON TABLE vibetype.event_category TO vibetype_anonymous;
GRANT SELECT ON TABLE vibetype.event_category TO vibetype_account;


--
-- Name: TABLE event_category_mapping; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT ON TABLE vibetype.event_category_mapping TO vibetype_anonymous;
GRANT SELECT,INSERT,DELETE ON TABLE vibetype.event_category_mapping TO vibetype_account;


--
-- Name: TABLE event_favorite; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT ON TABLE vibetype.event_favorite TO vibetype_anonymous;
GRANT SELECT,INSERT,DELETE ON TABLE vibetype.event_favorite TO vibetype_account;


--
-- Name: TABLE event_format; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT ON TABLE vibetype.event_format TO vibetype_anonymous;
GRANT SELECT ON TABLE vibetype.event_format TO vibetype_account;


--
-- Name: TABLE event_format_mapping; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT ON TABLE vibetype.event_format_mapping TO vibetype_anonymous;
GRANT SELECT,INSERT,DELETE ON TABLE vibetype.event_format_mapping TO vibetype_account;


--
-- Name: TABLE event_recommendation; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT ON TABLE vibetype.event_recommendation TO vibetype_account;


--
-- Name: TABLE event_upload; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT ON TABLE vibetype.event_upload TO vibetype_anonymous;
GRANT SELECT,INSERT,DELETE ON TABLE vibetype.event_upload TO vibetype_account;


--
-- Name: TABLE friendship; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE vibetype.friendship TO vibetype_account;


--
-- Name: TABLE guest_flat; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT ON TABLE vibetype.guest_flat TO vibetype_account;
GRANT SELECT ON TABLE vibetype.guest_flat TO vibetype_anonymous;


--
-- Name: TABLE legal_term; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT ON TABLE vibetype.legal_term TO vibetype_account;
GRANT SELECT ON TABLE vibetype.legal_term TO vibetype_anonymous;


--
-- Name: TABLE legal_term_acceptance; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT,INSERT ON TABLE vibetype.legal_term_acceptance TO vibetype_account;


--
-- Name: TABLE preference_event_category; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT,INSERT,DELETE ON TABLE vibetype.preference_event_category TO vibetype_account;


--
-- Name: TABLE preference_event_format; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT,INSERT,DELETE ON TABLE vibetype.preference_event_format TO vibetype_account;


--
-- Name: TABLE preference_event_location; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT,INSERT,DELETE ON TABLE vibetype.preference_event_location TO vibetype_account;


--
-- Name: TABLE preference_event_size; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT,INSERT,DELETE ON TABLE vibetype.preference_event_size TO vibetype_account;


--
-- Name: TABLE profile_picture; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT ON TABLE vibetype.profile_picture TO vibetype_anonymous;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE vibetype.profile_picture TO vibetype_account;
GRANT SELECT,DELETE ON TABLE vibetype.profile_picture TO vibetype;


--
-- Name: TABLE report; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT,INSERT ON TABLE vibetype.report TO vibetype_account;


--
-- Name: TABLE upload; Type: ACL; Schema: vibetype; Owner: ci
--

GRANT SELECT ON TABLE vibetype.upload TO vibetype_anonymous;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE vibetype.upload TO vibetype_account;
GRANT SELECT,UPDATE ON TABLE vibetype.upload TO vibetype;


--
-- Name: TABLE account; Type: ACL; Schema: vibetype_private; Owner: ci
--

GRANT SELECT ON TABLE vibetype_private.account TO grafana;


--
-- Name: TABLE achievement_code; Type: ACL; Schema: vibetype_private; Owner: ci
--

GRANT SELECT ON TABLE vibetype_private.achievement_code TO vibetype;


--
-- Name: TABLE notification; Type: ACL; Schema: vibetype_private; Owner: ci
--

GRANT SELECT ON TABLE vibetype_private.notification TO grafana;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: -; Owner: ci
--

ALTER DEFAULT PRIVILEGES FOR ROLE ci REVOKE ALL ON FUNCTIONS FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

