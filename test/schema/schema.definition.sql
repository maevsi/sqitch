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
-- Name: maevsi; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA maevsi;


ALTER SCHEMA maevsi OWNER TO postgres;

--
-- Name: SCHEMA maevsi; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA maevsi IS 'Is used by PostGraphile.';


--
-- Name: maevsi_private; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA maevsi_private;


ALTER SCHEMA maevsi_private OWNER TO postgres;

--
-- Name: SCHEMA maevsi_private; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA maevsi_private IS 'Contains account information and is not used by PostGraphile.';


--
-- Name: maevsi_test; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA maevsi_test;


ALTER SCHEMA maevsi_test OWNER TO postgres;

--
-- Name: SCHEMA maevsi_test; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA maevsi_test IS 'Schema for test functions.';


--
-- Name: sqitch; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA sqitch;


ALTER SCHEMA sqitch OWNER TO postgres;

--
-- Name: SCHEMA sqitch; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA sqitch IS 'Sqitch database deployment metadata v1.1.';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA maevsi;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'Provides password hashing functions.';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA maevsi;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'Functions to work with geospatial data.';


--
-- Name: achievement_type; Type: TYPE; Schema: maevsi; Owner: postgres
--

CREATE TYPE maevsi.achievement_type AS ENUM (
    'early_bird',
    'meet_the_team'
);


ALTER TYPE maevsi.achievement_type OWNER TO postgres;

--
-- Name: TYPE achievement_type; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TYPE maevsi.achievement_type IS 'Achievements that can be unlocked by users.';


--
-- Name: event_size; Type: TYPE; Schema: maevsi; Owner: postgres
--

CREATE TYPE maevsi.event_size AS ENUM (
    'small',
    'medium',
    'large',
    'huge'
);


ALTER TYPE maevsi.event_size OWNER TO postgres;

--
-- Name: TYPE event_size; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TYPE maevsi.event_size IS 'Possible event sizes: small, medium, large, huge.';


--
-- Name: jwt; Type: TYPE; Schema: maevsi; Owner: postgres
--

CREATE TYPE maevsi.jwt AS (
	id uuid,
	account_id uuid,
	account_username text,
	exp bigint,
	invitations uuid[],
	role text
);


ALTER TYPE maevsi.jwt OWNER TO postgres;

--
-- Name: event_unlock_response; Type: TYPE; Schema: maevsi; Owner: postgres
--

CREATE TYPE maevsi.event_unlock_response AS (
	author_account_username text,
	event_slug text,
	jwt maevsi.jwt
);


ALTER TYPE maevsi.event_unlock_response OWNER TO postgres;

--
-- Name: event_visibility; Type: TYPE; Schema: maevsi; Owner: postgres
--

CREATE TYPE maevsi.event_visibility AS ENUM (
    'public',
    'private'
);


ALTER TYPE maevsi.event_visibility OWNER TO postgres;

--
-- Name: TYPE event_visibility; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TYPE maevsi.event_visibility IS 'Possible visibilities of events and event groups: public, private.';


--
-- Name: invitation_feedback; Type: TYPE; Schema: maevsi; Owner: postgres
--

CREATE TYPE maevsi.invitation_feedback AS ENUM (
    'accepted',
    'canceled'
);


ALTER TYPE maevsi.invitation_feedback OWNER TO postgres;

--
-- Name: TYPE invitation_feedback; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TYPE maevsi.invitation_feedback IS 'Possible answers to an invitation: accepted, canceled.';


--
-- Name: invitation_feedback_paper; Type: TYPE; Schema: maevsi; Owner: postgres
--

CREATE TYPE maevsi.invitation_feedback_paper AS ENUM (
    'none',
    'paper',
    'digital'
);


ALTER TYPE maevsi.invitation_feedback_paper OWNER TO postgres;

--
-- Name: TYPE invitation_feedback_paper; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TYPE maevsi.invitation_feedback_paper IS 'Possible choices on how to receive a paper invitation: none, paper, digital.';


--
-- Name: language; Type: TYPE; Schema: maevsi; Owner: postgres
--

CREATE TYPE maevsi.language AS ENUM (
    'de',
    'en'
);


ALTER TYPE maevsi.language OWNER TO postgres;

--
-- Name: TYPE language; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TYPE maevsi.language IS 'Supported ISO 639 language codes.';


--
-- Name: social_network; Type: TYPE; Schema: maevsi; Owner: postgres
--

CREATE TYPE maevsi.social_network AS ENUM (
    'facebook',
    'instagram',
    'tiktok',
    'x'
);


ALTER TYPE maevsi.social_network OWNER TO postgres;

--
-- Name: TYPE social_network; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TYPE maevsi.social_network IS 'Social networks.';


--
-- Name: account_delete(text); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.account_delete(password text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $_$
DECLARE
  _current_account_id UUID;
BEGIN
  _current_account_id := current_setting('jwt.claims.account_id')::UUID;

  IF (EXISTS (SELECT 1 FROM maevsi_private.account WHERE account.id = _current_account_id AND account.password_hash = maevsi.crypt($1, account.password_hash))) THEN
    IF (EXISTS (SELECT 1 FROM maevsi.event WHERE event.author_account_id = _current_account_id)) THEN
      RAISE 'You still own events!' USING ERRCODE = 'foreign_key_violation';
    ELSE
      DELETE FROM maevsi_private.account WHERE account.id = _current_account_id;
    END IF;
  ELSE
    RAISE 'Account with given password not found!' USING ERRCODE = 'invalid_password';
  END IF;
END;
$_$;


ALTER FUNCTION maevsi.account_delete(password text) OWNER TO postgres;

--
-- Name: FUNCTION account_delete(password text); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.account_delete(password text) IS 'Allows to delete an account.';


--
-- Name: account_distances(uuid, double precision); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.account_distances(_event_id uuid, _max_distance double precision) RETURNS TABLE(account_id uuid, distance double precision)
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
BEGIN
  -- return account locations within a given radius around the location of an event
  RETURN QUERY
    WITH e AS (
      SELECT location_geometry FROM maevsi.event WHERE id = _event_id
    )
    SELECT a.id as account_id,  maevsi.ST_Distance(e.location_geometry, a.location) distance
    FROM e, maevsi_private.account a
    WHERE maevsi.ST_DWithin(e.location_geometry, a.location, _max_distance * 1000);
END; $$;


ALTER FUNCTION maevsi.account_distances(_event_id uuid, _max_distance double precision) OWNER TO postgres;

--
-- Name: FUNCTION account_distances(_event_id uuid, _max_distance double precision); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.account_distances(_event_id uuid, _max_distance double precision) IS 'Returns account locations within a given radius around the location of an event.';


--
-- Name: account_email_address_verification(uuid); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.account_email_address_verification(code uuid) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $_$
DECLARE
  _account maevsi_private.account;
BEGIN
  SELECT *
    FROM maevsi_private.account
    INTO _account
    WHERE account.email_address_verification = $1;

  IF (_account IS NULL) THEN
    RAISE 'Unknown verification code!' USING ERRCODE = 'no_data_found';
  END IF;

  IF (_account.email_address_verification_valid_until < CURRENT_TIMESTAMP) THEN
    RAISE 'Verification code expired!' USING ERRCODE = 'object_not_in_prerequisite_state';
  END IF;

  UPDATE maevsi_private.account
    SET email_address_verification = NULL
    WHERE email_address_verification = $1;
END;
$_$;


ALTER FUNCTION maevsi.account_email_address_verification(code uuid) OWNER TO postgres;

--
-- Name: FUNCTION account_email_address_verification(code uuid); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.account_email_address_verification(code uuid) IS 'Sets the account''s email address verification code to `NULL` for which the email address verification code equals the one passed and is up to date.';


--
-- Name: account_location_update(uuid, double precision, double precision); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.account_location_update(_account_id uuid, _latitude double precision, _longitude double precision) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
BEGIN
  -- SRID 4839: "ETRS89 / LCC Germany (N-E)", see https://www.crs-geo.eu/crs-pan-european.htm
  -- SRID 4326: "WGS 84" (default SRID)
  UPDATE maevsi_private.account SET
    location =  maevsi.ST_Transform( maevsi.ST_Point(_longitude, _latitude, 4326), 4839)
  WHERE id = _account_id;
END; $$;


ALTER FUNCTION maevsi.account_location_update(_account_id uuid, _latitude double precision, _longitude double precision) OWNER TO postgres;

--
-- Name: FUNCTION account_location_update(_account_id uuid, _latitude double precision, _longitude double precision); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.account_location_update(_account_id uuid, _latitude double precision, _longitude double precision) IS 'Updates an account''s location based on latitude and longitude (GPS coordinates).';


--
-- Name: account_password_change(text, text); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.account_password_change(password_current text, password_new text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $_$
DECLARE
  _current_account_id UUID;
BEGIN
  IF (char_length($2) < 8) THEN
      RAISE 'New password too short!' USING ERRCODE = 'invalid_parameter_value';
  END IF;

  _current_account_id := current_setting('jwt.claims.account_id')::UUID;

  IF (EXISTS (SELECT 1 FROM maevsi_private.account WHERE account.id = _current_account_id AND account.password_hash = maevsi.crypt($1, account.password_hash))) THEN
    UPDATE maevsi_private.account SET password_hash = maevsi.crypt($2, maevsi.gen_salt('bf')) WHERE account.id = _current_account_id;
  ELSE
    RAISE 'Account with given password not found!' USING ERRCODE = 'invalid_password';
  END IF;
END;
$_$;


ALTER FUNCTION maevsi.account_password_change(password_current text, password_new text) OWNER TO postgres;

--
-- Name: FUNCTION account_password_change(password_current text, password_new text); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.account_password_change(password_current text, password_new text) IS 'Allows to change an account''s password.';


--
-- Name: account_password_reset(uuid, text); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.account_password_reset(code uuid, password text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $_$
DECLARE
  _account maevsi_private.account;
BEGIN
  IF (char_length($2) < 8) THEN
    RAISE 'Password too short!' USING ERRCODE = 'invalid_parameter_value';
  END IF;

  SELECT *
    FROM maevsi_private.account
    INTO _account
    WHERE account.password_reset_verification = $1;

  IF (_account IS NULL) THEN
    RAISE 'Unknown reset code!' USING ERRCODE = 'no_data_found';
  END IF;

  IF (_account.password_reset_verification_valid_until < CURRENT_TIMESTAMP) THEN
    RAISE 'Reset code expired!' USING ERRCODE = 'object_not_in_prerequisite_state';
  END IF;

  UPDATE maevsi_private.account
    SET
      password_hash = maevsi.crypt($2, maevsi.gen_salt('bf')),
      password_reset_verification = NULL
    WHERE account.password_reset_verification = $1;
END;
$_$;


ALTER FUNCTION maevsi.account_password_reset(code uuid, password text) OWNER TO postgres;

--
-- Name: FUNCTION account_password_reset(code uuid, password text); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.account_password_reset(code uuid, password text) IS 'Sets a new password for an account if there was a request to do so before that''s still up to date.';


--
-- Name: account_password_reset_request(text, text); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.account_password_reset_request(email_address text, language text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $_$
DECLARE
  _notify_data RECORD;
BEGIN
  WITH updated AS (
    UPDATE maevsi_private.account
      SET password_reset_verification = gen_random_uuid()
      WHERE account.email_address = $1
      RETURNING *
  ) SELECT
    account.username,
    updated.email_address,
    updated.password_reset_verification,
    updated.password_reset_verification_valid_until
    FROM updated, maevsi.account
    WHERE updated.id = account.id
    INTO _notify_data;

  IF (_notify_data IS NULL) THEN
    -- noop
  ELSE
    INSERT INTO maevsi_private.notification (channel, payload) VALUES (
      'account_password_reset_request',
      jsonb_pretty(jsonb_build_object(
        'account', _notify_data,
        'template', jsonb_build_object('language', $2)
      ))
    );
  END IF;
END;
$_$;


ALTER FUNCTION maevsi.account_password_reset_request(email_address text, language text) OWNER TO postgres;

--
-- Name: FUNCTION account_password_reset_request(email_address text, language text); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.account_password_reset_request(email_address text, language text) IS 'Sets a new password reset verification code for an account.';


--
-- Name: account_registration(text, text, text, text); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.account_registration(username text, email_address text, password text, language text) RETURNS uuid
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _new_account_private maevsi_private.account;
  _new_account_public maevsi.account;
  _new_account_notify RECORD;
BEGIN
  IF (char_length(account_registration.password) < 8) THEN
    RAISE 'Password too short!' USING ERRCODE = 'invalid_parameter_value';
  END IF;

  IF (EXISTS (SELECT 1 FROM maevsi.account WHERE account.username = account_registration.username)) THEN
    RAISE 'An account with this username already exists!' USING ERRCODE = 'unique_violation';
  END IF;

  IF (EXISTS (SELECT 1 FROM maevsi_private.account WHERE account.email_address = account_registration.email_address)) THEN
    RAISE 'An account with this email address already exists!' USING ERRCODE = 'unique_violation';
  END IF;

  INSERT INTO maevsi_private.account(email_address, password_hash, last_activity) VALUES
    (account_registration.email_address, maevsi.crypt(account_registration.password, maevsi.gen_salt('bf')), CURRENT_TIMESTAMP)
    RETURNING * INTO _new_account_private;

  INSERT INTO maevsi.account(id, username) VALUES
    (_new_account_private.id, account_registration.username)
    RETURNING * INTO _new_account_public;

  SELECT
    _new_account_public.username,
    _new_account_private.email_address,
    _new_account_private.email_address_verification,
    _new_account_private.email_address_verification_valid_until
  INTO _new_account_notify;

  INSERT INTO maevsi.contact(account_id, author_account_id) VALUES (_new_account_private.id, _new_account_private.id);

  INSERT INTO maevsi_private.notification (channel, payload) VALUES (
    'account_registration',
    jsonb_pretty(jsonb_build_object(
      'account', row_to_json(_new_account_notify),
      'template', jsonb_build_object('language', account_registration.language)
    ))
  );

  RETURN _new_account_public.id;
END;
$$;


ALTER FUNCTION maevsi.account_registration(username text, email_address text, password text, language text) OWNER TO postgres;

--
-- Name: FUNCTION account_registration(username text, email_address text, password text, language text); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.account_registration(username text, email_address text, password text, language text) IS 'Creates a contact and registers an account referencing it.';


--
-- Name: account_registration_refresh(uuid, text); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.account_registration_refresh(account_id uuid, language text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $_$
DECLARE
  _new_account_notify RECORD;
BEGIN
  RAISE 'Refreshing registrations is currently not available due to missing rate limiting!' USING ERRCODE = 'deprecated_feature';

  IF (NOT EXISTS (SELECT 1 FROM maevsi_private.account WHERE account.id = $1)) THEN
    RAISE 'An account with this account id does not exists!' USING ERRCODE = 'invalid_parameter_value';
  END IF;

  WITH updated AS (
    UPDATE maevsi_private.account
      SET email_address_verification = DEFAULT
      WHERE account.id = $1
      RETURNING *
  ) SELECT
    account.username,
    updated.email_address,
    updated.email_address_verification,
    updated.email_address_verification_valid_until
    FROM updated, maevsi.account
    WHERE updated.id = account.id
    INTO _new_account_notify;

  INSERT INTO maevsi_private.notification (channel, payload) VALUES (
    'account_registration',
    jsonb_pretty(jsonb_build_object(
      'account', row_to_json(_new_account_notify),
      'template', jsonb_build_object('language', $2)
    ))
  );
END;
$_$;


ALTER FUNCTION maevsi.account_registration_refresh(account_id uuid, language text) OWNER TO postgres;

--
-- Name: FUNCTION account_registration_refresh(account_id uuid, language text); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.account_registration_refresh(account_id uuid, language text) IS 'Refreshes an account''s email address verification validity period.';


--
-- Name: account_upload_quota_bytes(); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.account_upload_quota_bytes() RETURNS bigint
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
BEGIN
  RETURN (SELECT upload_quota_bytes FROM maevsi_private.account WHERE account.id = current_setting('jwt.claims.account_id')::UUID);
END;
$$;


ALTER FUNCTION maevsi.account_upload_quota_bytes() OWNER TO postgres;

--
-- Name: FUNCTION account_upload_quota_bytes(); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.account_upload_quota_bytes() IS 'Gets the total upload quota in bytes for the invoking account.';


--
-- Name: achievement_unlock(uuid, text); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.achievement_unlock(code uuid, alias text) RETURNS uuid
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $_$
DECLARE
  _account_id UUID;
  _achievement maevsi.achievement_type;
  _achievement_id UUID;
BEGIN
  _account_id := maevsi.invoker_account_id();

  SELECT achievement
    FROM maevsi_private.achievement_code
    INTO _achievement
    WHERE achievement_code.id = $1 OR achievement_code.alias = $2;

  IF (_achievement IS NULL) THEN
    RAISE 'Unknown achievement!' USING ERRCODE = 'no_data_found';
  END IF;

  IF (_account_id IS NULL) THEN
    RAISE 'Unknown account!' USING ERRCODE = 'no_data_found';
  END IF;

  _achievement_id := (
    SELECT id FROM maevsi.achievement
    WHERE achievement.account_id = _account_id AND achievement.achievement = _achievement
  );

  IF (_achievement_id IS NULL) THEN
    INSERT INTO maevsi.achievement(account_id, achievement)
      VALUES (_account_id,  _achievement)
      RETURNING achievement.id INTO _achievement_id;
  END IF;

  RETURN _achievement_id;
END;
$_$;


ALTER FUNCTION maevsi.achievement_unlock(code uuid, alias text) OWNER TO postgres;

--
-- Name: FUNCTION achievement_unlock(code uuid, alias text); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.achievement_unlock(code uuid, alias text) IS 'Inserts an achievement unlock for the user that gave an existing achievement code.';


--
-- Name: authenticate(text, text); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.authenticate(username text, password text) RETURNS maevsi.jwt
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _account_id UUID;
  _jwt_id UUID := gen_random_uuid();
  _jwt_exp BIGINT := EXTRACT(EPOCH FROM ((SELECT date_trunc('second', CURRENT_TIMESTAMP::TIMESTAMP WITH TIME ZONE)) + COALESCE(current_setting('maevsi.jwt_expiry_duration', true), '1 day')::INTERVAL));
  _jwt maevsi.jwt;
  _username TEXT;
BEGIN
  IF (authenticate.username = '' AND authenticate.password = '') THEN
    -- Authenticate as guest.
    _jwt := (_jwt_id, NULL, NULL, _jwt_exp, maevsi.invitation_claim_array(), 'maevsi_anonymous')::maevsi.jwt;
  ELSIF (authenticate.username IS NOT NULL AND authenticate.password IS NOT NULL) THEN
    -- if authenticate.username contains @ then treat it as an email adress otherwise as a user name
    IF (strpos(authenticate.username, '@') = 0) THEN
      SELECT id FROM maevsi.account WHERE account.username = authenticate.username INTO _account_id;
    ELSE
      SELECT id FROM maevsi_private.account WHERE account.email_address = authenticate.username INTO _account_id;
    END IF;

    IF (_account_id IS NULL) THEN
      RAISE 'Account not found!' USING ERRCODE = 'no_data_found';
    END IF;

    SELECT account.username INTO _username FROM maevsi.account WHERE id = _account_id;

    IF ((
        SELECT account.email_address_verification
        FROM maevsi_private.account
        WHERE
              account.id = _account_id
          AND account.password_hash = maevsi.crypt(authenticate.password, account.password_hash)
      ) IS NOT NULL) THEN
      RAISE 'Account not verified!' USING ERRCODE = 'object_not_in_prerequisite_state';
    END IF;

    WITH updated AS (
      UPDATE maevsi_private.account
      SET (last_activity, password_reset_verification) = (DEFAULT, NULL)
      WHERE
            account.id = _account_id
        AND account.email_address_verification IS NULL -- Has been checked before, but better safe than sorry.
        AND account.password_hash = maevsi.crypt(authenticate.password, account.password_hash)
      RETURNING *
    ) SELECT _jwt_id, updated.id, _username, _jwt_exp, NULL, 'maevsi_account'
      FROM updated
      INTO _jwt;

    IF (_jwt IS NULL) THEN
      RAISE 'Could not get token!' USING ERRCODE = 'no_data_found';
    END IF;
  END IF;

  INSERT INTO maevsi_private.jwt(id, token) VALUES (_jwt_id, _jwt);
  RETURN _jwt;
END;
$$;


ALTER FUNCTION maevsi.authenticate(username text, password text) OWNER TO postgres;

--
-- Name: FUNCTION authenticate(username text, password text); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.authenticate(username text, password text) IS 'Creates a JWT token that will securely identify an account and give it certain permissions.';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: event; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.event (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    author_account_id uuid NOT NULL,
    description text,
    "end" timestamp with time zone,
    invitee_count_maximum integer,
    is_archived boolean DEFAULT false NOT NULL,
    is_in_person boolean,
    is_remote boolean,
    location text,
    location_geometry maevsi.geometry(Point,4839),
    name text NOT NULL,
    slug text NOT NULL,
    start timestamp with time zone NOT NULL,
    url text,
    visibility maevsi.event_visibility NOT NULL,
    CONSTRAINT event_description_check CHECK (((char_length(description) > 0) AND (char_length(description) < 1000000))),
    CONSTRAINT event_invitee_count_maximum_check CHECK ((invitee_count_maximum > 0)),
    CONSTRAINT event_location_check CHECK (((char_length(location) > 0) AND (char_length(location) < 300))),
    CONSTRAINT event_name_check CHECK (((char_length(name) > 0) AND (char_length(name) < 100))),
    CONSTRAINT event_slug_check CHECK (((char_length(slug) < 100) AND (slug ~ '^[-A-Za-z0-9]+$'::text))),
    CONSTRAINT event_url_check CHECK (((char_length(url) < 300) AND (url ~ '^https:\/\/'::text)))
);


ALTER TABLE maevsi.event OWNER TO postgres;

--
-- Name: TABLE event; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.event IS 'An event.';


--
-- Name: COLUMN event.id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event.id IS '@omit create,update
The event''s internal id.';


--
-- Name: COLUMN event.created_at; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event.created_at IS '@omit create,update
Timestamp of when the event was created, defaults to the current timestamp.';


--
-- Name: COLUMN event.author_account_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event.author_account_id IS 'The event author''s id.';


--
-- Name: COLUMN event.description; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event.description IS 'The event''s description.';


--
-- Name: COLUMN event."end"; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event."end" IS 'The event''s end date and time, with timezone.';


--
-- Name: COLUMN event.invitee_count_maximum; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event.invitee_count_maximum IS 'The event''s maximum invitee count.';


--
-- Name: COLUMN event.is_archived; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event.is_archived IS 'Indicates whether the event is archived.';


--
-- Name: COLUMN event.is_in_person; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event.is_in_person IS 'Indicates whether the event takes place in person.';


--
-- Name: COLUMN event.is_remote; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event.is_remote IS 'Indicates whether the event takes place remotely.';


--
-- Name: COLUMN event.location; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event.location IS 'The event''s location as it can be shown on a map.';


--
-- Name: COLUMN event.location_geometry; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event.location_geometry IS 'The event''s geometric location.';


--
-- Name: COLUMN event.name; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event.name IS 'The event''s name.';


--
-- Name: COLUMN event.slug; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event.slug IS 'The event''s name, slugified.';


--
-- Name: COLUMN event.start; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event.start IS 'The event''s start date and time, with timezone.';


--
-- Name: COLUMN event.url; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event.url IS 'The event''s unified resource locator.';


--
-- Name: COLUMN event.visibility; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event.visibility IS 'The event''s visibility.';


--
-- Name: event_delete(uuid, text); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.event_delete(id uuid, password text) RETURNS maevsi.event
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $_$
DECLARE
  _current_account_id UUID;
  _event_deleted maevsi.event;
BEGIN
  _current_account_id := current_setting('jwt.claims.account_id')::UUID;

  IF (EXISTS (SELECT 1 FROM maevsi_private.account WHERE account.id = _current_account_id AND account.password_hash = maevsi.crypt($2, account.password_hash))) THEN
    DELETE
      FROM maevsi.event
      WHERE
            "event".id = $1
        AND "event".author_account_id = _current_account_id
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
$_$;


ALTER FUNCTION maevsi.event_delete(id uuid, password text) OWNER TO postgres;

--
-- Name: FUNCTION event_delete(id uuid, password text); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.event_delete(id uuid, password text) IS 'Allows to delete an event.';


--
-- Name: event_distances(uuid, double precision); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.event_distances(_account_id uuid, _max_distance double precision) RETURNS TABLE(event_id uuid, distance double precision)
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
    WITH a AS (
      SELECT location FROM maevsi_private.account WHERE id = _account_id
    )
    SELECT e.id as event_id, maevsi.ST_Distance(a.location, e.location_geometry) distance
    FROM a, maevsi.event e
    WHERE maevsi.ST_DWithin(a.location, e.location_geometry, _max_distance * 1000);
END; $$;


ALTER FUNCTION maevsi.event_distances(_account_id uuid, _max_distance double precision) OWNER TO postgres;

--
-- Name: FUNCTION event_distances(_account_id uuid, _max_distance double precision); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.event_distances(_account_id uuid, _max_distance double precision) IS 'Returns event locations within a given radius around the location of an account.';


--
-- Name: event_invitee_count_maximum(uuid); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.event_invitee_count_maximum(event_id uuid) RETURNS integer
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $_$
BEGIN
  RETURN (
    SELECT "event".invitee_count_maximum
    FROM maevsi.event
    WHERE
      "event".id = $1
      AND ( -- Copied from `event_select` POLICY.
            (
              "event".visibility = 'public'
              AND
              (
                "event".invitee_count_maximum IS NULL
                OR
                "event".invitee_count_maximum > (maevsi.invitee_count(id)) -- Using the function here is required as there would otherwise be infinite recursion.
              )
            )
        OR (
          maevsi.invoker_account_id() IS NOT NULL
          AND
          "event".author_account_id = maevsi.invoker_account_id()
        )
        OR  "event".id IN (SELECT maevsi_private.events_invited())
      )
  );
END
$_$;


ALTER FUNCTION maevsi.event_invitee_count_maximum(event_id uuid) OWNER TO postgres;

--
-- Name: FUNCTION event_invitee_count_maximum(event_id uuid); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.event_invitee_count_maximum(event_id uuid) IS 'Add a function that returns the maximum invitee count of an accessible event.';


--
-- Name: event_is_existing(uuid, text); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.event_is_existing(author_account_id uuid, slug text) RETURNS boolean
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $_$
BEGIN
  IF (EXISTS (SELECT 1 FROM maevsi.event WHERE "event".author_account_id = $1 AND "event".slug = $2)) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
$_$;


ALTER FUNCTION maevsi.event_is_existing(author_account_id uuid, slug text) OWNER TO postgres;

--
-- Name: FUNCTION event_is_existing(author_account_id uuid, slug text); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.event_is_existing(author_account_id uuid, slug text) IS 'Shows if an event exists.';


--
-- Name: event_location_update(uuid, double precision, double precision); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.event_location_update(_event_id uuid, _latitude double precision, _longitude double precision) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
BEGIN
  -- SRID 4839: "ETRS89 / LCC Germany (N-E)", see https://www.crs-geo.eu/crs-pan-european.htm
  -- SRID 4326: "WGS 84" (default SRID)
  UPDATE maevsi.event SET
    location_geometry =  maevsi.ST_Transform( maevsi.ST_Point(_longitude, _latitude, 4326), 4839)
  WHERE id = _event_id;
END; $$;


ALTER FUNCTION maevsi.event_location_update(_event_id uuid, _latitude double precision, _longitude double precision) OWNER TO postgres;

--
-- Name: FUNCTION event_location_update(_event_id uuid, _latitude double precision, _longitude double precision); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.event_location_update(_event_id uuid, _latitude double precision, _longitude double precision) IS 'Updates an event''s location based on latitude and longitude (GPS coordinates).';


--
-- Name: event_unlock(uuid); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.event_unlock(invitation_id uuid) RETURNS maevsi.event_unlock_response
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $_$
DECLARE
  _jwt_id UUID;
  _jwt maevsi.jwt;
  _event maevsi.event;
  _event_author_account_username TEXT;
  _event_id UUID;
BEGIN
  _jwt_id := current_setting('jwt.claims.id', true)::UUID;
  _jwt := (
    _jwt_id,
    maevsi.invoker_account_id(), -- prevent empty string cast to UUID
    current_setting('jwt.claims.account_username', true)::TEXT,
    current_setting('jwt.claims.exp', true)::BIGINT,
    (SELECT ARRAY(SELECT DISTINCT UNNEST(maevsi.invitation_claim_array() || $1) ORDER BY 1)),
    current_setting('jwt.claims.role', true)::TEXT
  )::maevsi.jwt;

  UPDATE maevsi_private.jwt
  SET token = _jwt
  WHERE id = _jwt_id;

  _event_id := (
    SELECT event_id FROM maevsi.invitation
    WHERE invitation.id = $1
  );

  IF (_event_id IS NULL) THEN
    RAISE 'No invitation for this invitation id found!' USING ERRCODE = 'no_data_found';
  END IF;

  SELECT *
    FROM maevsi.event
    WHERE id = _event_id
    INTO _event;

  IF (_event IS NULL) THEN
    RAISE 'No event for this invitation id found!' USING ERRCODE = 'no_data_found';
  END IF;

  _event_author_account_username := (
    SELECT username
    FROM maevsi.account
    WHERE id = _event.author_account_id
  );

  IF (_event_author_account_username IS NULL) THEN
    RAISE 'No event author username for this invitation id found!' USING ERRCODE = 'no_data_found';
  END IF;

  RETURN (_event_author_account_username, _event.slug, _jwt)::maevsi.event_unlock_response;
END $_$;


ALTER FUNCTION maevsi.event_unlock(invitation_id uuid) OWNER TO postgres;

--
-- Name: FUNCTION event_unlock(invitation_id uuid); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.event_unlock(invitation_id uuid) IS 'Assigns an invitation to the current session.';


--
-- Name: events_organized(); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.events_organized() RETURNS TABLE(event_id uuid)
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
DECLARE
  account_id UUID;
BEGIN
  account_id := maevsi.invoker_account_id();

  RETURN QUERY
    SELECT id FROM maevsi.event
    WHERE
      account_id IS NOT NULL
      AND
      "event".author_account_id = account_id;
END
$$;


ALTER FUNCTION maevsi.events_organized() OWNER TO postgres;

--
-- Name: FUNCTION events_organized(); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.events_organized() IS 'Add a function that returns all event ids for which the invoker is the author.';


--
-- Name: get_account_location_coordinates(uuid); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.get_account_location_coordinates(_account_id uuid) RETURNS double precision[]
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
DECLARE
  _latitude DOUBLE PRECISION;
  _longitude DOUBLE PRECISION;
BEGIN
  SELECT  maevsi.ST_Y( maevsi.ST_Transform(location, 4326)),  maevsi.ST_X( maevsi.ST_Transform(location, 4326))
  INTO _latitude, _longitude
  FROM maevsi_private.account
  WHERE id = _account_id;
  RETURN ARRAY[_latitude, _longitude];
END; $$;


ALTER FUNCTION maevsi.get_account_location_coordinates(_account_id uuid) OWNER TO postgres;

--
-- Name: FUNCTION get_account_location_coordinates(_account_id uuid); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.get_account_location_coordinates(_account_id uuid) IS 'Returns an array with latitude and longitude of the account''s current location data';


--
-- Name: get_event_location_coordinates(uuid); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.get_event_location_coordinates(_event_id uuid) RETURNS double precision[]
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
DECLARE
  _latitude DOUBLE PRECISION;
  _longitude DOUBLE PRECISION;
BEGIN
  SELECT  maevsi.ST_Y( maevsi.ST_Transform(location_geometry, 4326)),  maevsi.ST_X( maevsi.ST_Transform(location_geometry, 4326))
  INTO _latitude, _longitude
  FROM maevsi.event
  WHERE id = _event_id;
  RETURN ARRAY[_latitude, _longitude];
END; $$;


ALTER FUNCTION maevsi.get_event_location_coordinates(_event_id uuid) OWNER TO postgres;

--
-- Name: FUNCTION get_event_location_coordinates(_event_id uuid); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.get_event_location_coordinates(_event_id uuid) IS 'Returns an array with latitude and longitude of the event''s current location data.';


--
-- Name: invitation_claim_array(); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.invitation_claim_array() RETURNS uuid[]
    LANGUAGE plpgsql STABLE STRICT
    AS $$
DECLARE
  _invitation_ids UUID[];
  _invitation_ids_unblocked UUID[] := ARRAY[]::UUID[];
  _invitation_id UUID;
BEGIN
  _invitation_ids := string_to_array(replace(btrim(current_setting('jwt.claims.invitations', true), '[]'), '"', ''), ',')::UUID[];

  IF _invitation_ids IS NOT NULL THEN
    FOREACH _invitation_id IN ARRAY _invitation_ids
    LOOP
      -- omit invitations authored by a blocked account
      IF NOT EXISTS(
        SELECT 1
        FROM maevsi.invitation i
        JOIN maevsi.contact c ON i.contact_id = c.contact_id
        JOIN maevsi.account_block b ON c.author_account_id = b.blocked_account_id
       WHERE i.id = _invitation_id AND b.author_account_id = maevsi.invoker_account_id()
      ) THEN
        _invitation_ids_unblocked := append_invitation_array(result_invitation_ids, _invitation_id);
      END IF;
    END LOOP;
  END IF;
  RETURN _invitation_ids_unblocked;
END
$$;


ALTER FUNCTION maevsi.invitation_claim_array() OWNER TO postgres;

--
-- Name: FUNCTION invitation_claim_array(); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.invitation_claim_array() IS 'Returns the current invitation claims as UUID array.';


--
-- Name: invitation_contact_ids(); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.invitation_contact_ids() RETURNS TABLE(contact_id uuid)
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY
    -- get all contacts for invitations
    SELECT invitation.contact_id
    FROM maevsi.invitation
    WHERE
      (
        -- that are known to the invoker
        invitation.id = ANY (maevsi.invitation_claim_array())
      OR
        -- or for events organized by the invoker
        invitation.event_id IN (SELECT maevsi.events_organized())
      )
      AND
        -- except contacts authored by a blocked account or referring to a blocked account
        invitation.contact_id NOT IN (
          SELECT contact.id
          FROM maevsi.contact
          WHERE
              contact.account_id IS NULL -- TODO: evaluate if this null check is necessary
            OR
              contact.account_id IN (
                SELECT blocked_account_id
                FROM maevsi.account_block
                WHERE author_account_id = maevsi.invoker_account_id()
                UNION ALL
                SELECT author_account_id
                FROM maevsi.account_block
                WHERE blocked_account_id = maevsi.invoker_account_id()
              )
            OR
              contact.author_account_id IN (
                SELECT blocked_account_id
                FROM maevsi.account_block
                WHERE author_account_id = maevsi.invoker_account_id()
                UNION ALL
                SELECT author_account_id
                FROM maevsi.account_block
                WHERE blocked_account_id = maevsi.invoker_account_id()
              )
        );
END;
$$;


ALTER FUNCTION maevsi.invitation_contact_ids() OWNER TO postgres;

--
-- Name: FUNCTION invitation_contact_ids(); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.invitation_contact_ids() IS 'Returns contact ids that are accessible through invitations.';


--
-- Name: invite(uuid, text); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.invite(invitation_id uuid, language text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $_$
DECLARE
  _contact RECORD;
  _email_address TEXT;
  _event RECORD;
  _event_author_profile_picture_upload_id UUID;
  _event_author_profile_picture_upload_storage_key TEXT;
  _event_author_username TEXT;
  _invitation RECORD;
BEGIN
  -- Invitation UUID
  SELECT * FROM maevsi.invitation INTO _invitation WHERE invitation.id = $1;

  IF (
    _invitation IS NULL
    OR
    _invitation.event_id NOT IN (SELECT maevsi.events_organized()) -- Initial validation, every query below is expected to be secure.
  ) THEN
    RAISE 'Invitation not accessible!' USING ERRCODE = 'no_data_found';
  END IF;

  -- Event
  SELECT * FROM maevsi.event INTO _event WHERE "event".id = _invitation.event_id;

  IF (_event IS NULL) THEN
    RAISE 'Event not accessible!' USING ERRCODE = 'no_data_found';
  END IF;

  -- Contact
  SELECT account_id, email_address FROM maevsi.contact INTO _contact WHERE contact.id = _invitation.contact_id;

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
    SELECT email_address FROM maevsi_private.account INTO _email_address WHERE account.id = _contact.account_id;

    IF (_email_address IS NULL) THEN
      RAISE 'Account email address not accessible!' USING ERRCODE = 'no_data_found';
    END IF;
  END IF;

  -- Event author username
  SELECT username FROM maevsi.account INTO _event_author_username WHERE account.id = _event.author_account_id;

  -- Event author profile picture storage key
  SELECT upload_id FROM maevsi.profile_picture INTO _event_author_profile_picture_upload_id WHERE profile_picture.account_id = _event.author_account_id;
  SELECT storage_key FROM maevsi.upload INTO _event_author_profile_picture_upload_storage_key WHERE upload.id = _event_author_profile_picture_upload_id;

  INSERT INTO maevsi_private.notification (channel, payload)
    VALUES (
      'event_invitation',
      jsonb_pretty(jsonb_build_object(
        'data', jsonb_build_object(
          'emailAddress', _email_address,
          'event', _event,
          'eventAuthorProfilePictureUploadStorageKey', _event_author_profile_picture_upload_storage_key,
          'eventAuthorUsername', _event_author_username,
          'invitationId', _invitation.id
        ),
        'template', jsonb_build_object('language', $2)
      ))
    );
END;
$_$;


ALTER FUNCTION maevsi.invite(invitation_id uuid, language text) OWNER TO postgres;

--
-- Name: FUNCTION invite(invitation_id uuid, language text); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.invite(invitation_id uuid, language text) IS 'Adds a notification for the invitation channel.';


--
-- Name: invitee_count(uuid); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.invitee_count(event_id uuid) RETURNS integer
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $_$
BEGIN
  RETURN (SELECT COUNT(1) FROM maevsi.invitation WHERE invitation.event_id = $1);
END;
$_$;


ALTER FUNCTION maevsi.invitee_count(event_id uuid) OWNER TO postgres;

--
-- Name: FUNCTION invitee_count(event_id uuid); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.invitee_count(event_id uuid) IS 'Returns the invitee count for an event.';


--
-- Name: invoker_account_id(); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.invoker_account_id() RETURNS uuid
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
BEGIN
  RETURN NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID;
END;
$$;


ALTER FUNCTION maevsi.invoker_account_id() OWNER TO postgres;

--
-- Name: FUNCTION invoker_account_id(); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.invoker_account_id() IS 'Returns the session''s account id.';


--
-- Name: jwt_refresh(uuid); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.jwt_refresh(jwt_id uuid) RETURNS maevsi.jwt
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $_$
DECLARE
  _epoch_now BIGINT := EXTRACT(EPOCH FROM (SELECT date_trunc('second', CURRENT_TIMESTAMP::TIMESTAMP WITH TIME ZONE)));
  _jwt maevsi.jwt;
BEGIN
  SELECT (token).id, (token).account_id, (token).account_username, (token)."exp", (token).invitations, (token).role INTO _jwt
  FROM maevsi_private.jwt
  WHERE   id = $1
  AND     (token)."exp" >= _epoch_now;

  IF (_jwt IS NULL) THEN
    RETURN NULL;
  ELSE
    UPDATE maevsi_private.jwt
    SET token.exp = EXTRACT(EPOCH FROM ((SELECT date_trunc('second', CURRENT_TIMESTAMP::TIMESTAMP WITH TIME ZONE)) + COALESCE(current_setting('maevsi.jwt_expiry_duration', true), '1 day')::INTERVAL))
    WHERE id = $1;

    UPDATE maevsi_private.account
    SET last_activity = DEFAULT
    WHERE account.id = _jwt.account_id;

    RETURN (
      SELECT token
      FROM maevsi_private.jwt
      WHERE   id = $1
      AND     (token)."exp" >= _epoch_now
    );
  END IF;
END;
$_$;


ALTER FUNCTION maevsi.jwt_refresh(jwt_id uuid) OWNER TO postgres;

--
-- Name: FUNCTION jwt_refresh(jwt_id uuid); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.jwt_refresh(jwt_id uuid) IS 'Refreshes a JWT.';


--
-- Name: legal_term_change(); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.legal_term_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'Changes to legal terms are not allowed to keep historical integrity. Publish a new version instead.';
  RETURN NULL;
END;
$$;


ALTER FUNCTION maevsi.legal_term_change() OWNER TO postgres;

--
-- Name: notification_acknowledge(uuid, boolean); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.notification_acknowledge(id uuid, is_acknowledged boolean) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $_$
BEGIN
  IF (EXISTS (SELECT 1 FROM maevsi_private.notification WHERE "notification".id = $1)) THEN
    UPDATE maevsi_private.notification SET is_acknowledged = $2 WHERE "notification".id = $1;
  ELSE
    RAISE 'Notification with given id not found!' USING ERRCODE = 'no_data_found';
  END IF;
END;
$_$;


ALTER FUNCTION maevsi.notification_acknowledge(id uuid, is_acknowledged boolean) OWNER TO postgres;

--
-- Name: FUNCTION notification_acknowledge(id uuid, is_acknowledged boolean); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.notification_acknowledge(id uuid, is_acknowledged boolean) IS 'Allows to set the acknowledgement state of a notification.';


--
-- Name: profile_picture_set(uuid); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.profile_picture_set(upload_id uuid) RETURNS void
    LANGUAGE plpgsql STRICT
    AS $_$
BEGIN
  INSERT INTO maevsi.profile_picture(account_id, upload_id)
  VALUES (
    current_setting('jwt.claims.account_id')::UUID,
    $1
  )
  ON CONFLICT (account_id)
  DO UPDATE
  SET upload_id = $1;
END;
$_$;


ALTER FUNCTION maevsi.profile_picture_set(upload_id uuid) OWNER TO postgres;

--
-- Name: FUNCTION profile_picture_set(upload_id uuid); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.profile_picture_set(upload_id uuid) IS 'Sets the picture with the given upload id as the invoker''s profile picture.';


--
-- Name: trigger_contact_update_account_id(); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.trigger_contact_update_account_id() RETURNS trigger
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
  BEGIN
    IF (
      -- invoked without account it
      maevsi.invoker_account_id() IS NULL
      OR
      -- invoked with account it
      -- and
      (
        -- updating own account's contact
        OLD.account_id = maevsi.invoker_account_id()
        AND
        OLD.author_account_id = maevsi.invoker_account_id()
        AND
        (
          -- trying to detach from account
          NEW.account_id != OLD.account_id
          OR
          NEW.author_account_id != OLD.author_account_id
        )
      )
    ) THEN
      RAISE 'You cannot remove the association of your account''s own contact with your account.' USING ERRCODE = 'foreign_key_violation';
    END IF;

    RETURN NEW;
  END;
$$;


ALTER FUNCTION maevsi.trigger_contact_update_account_id() OWNER TO postgres;

--
-- Name: FUNCTION trigger_contact_update_account_id(); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.trigger_contact_update_account_id() IS 'Prevents invalid updates to contacts.';


--
-- Name: trigger_invitation_update(); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.trigger_invitation_update() RETURNS trigger
    LANGUAGE plpgsql STRICT
    AS $$
DECLARE
  whitelisted_cols TEXT[] := ARRAY['feedback', 'feedback_paper'];
BEGIN
  IF
      TG_OP = 'UPDATE'
    AND ( -- Invited.
      OLD.id = ANY (maevsi.invitation_claim_array())
      OR
      (
        maevsi.invoker_account_id() IS NOT NULL
        AND
        OLD.contact_id IN (
          SELECT id
          FROM maevsi.contact
          WHERE contact.account_id = maevsi.invoker_account_id()
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
    NEW.updated_by = maevsi.invoker_account_id();
    RETURN NEW;
  END IF;
END $$;


ALTER FUNCTION maevsi.trigger_invitation_update() OWNER TO postgres;

--
-- Name: FUNCTION trigger_invitation_update(); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.trigger_invitation_update() IS 'Checks if the caller has permissions to alter the desired columns.';


--
-- Name: upload; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.upload (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    account_id uuid NOT NULL,
    name text,
    size_byte bigint NOT NULL,
    storage_key text,
    type text DEFAULT 'image'::text NOT NULL,
    CONSTRAINT upload_name_check CHECK (((char_length(name) > 0) AND (char_length(name) < 300))),
    CONSTRAINT upload_size_byte_check CHECK ((size_byte > 0))
);


ALTER TABLE maevsi.upload OWNER TO postgres;

--
-- Name: TABLE upload; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.upload IS 'An upload.';


--
-- Name: COLUMN upload.id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.upload.id IS '@omit create,update
The upload''s internal id.';


--
-- Name: COLUMN upload.created_at; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.upload.created_at IS '@omit create,update
Timestamp of when the upload was created, defaults to the current timestamp.';


--
-- Name: COLUMN upload.account_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.upload.account_id IS 'The uploader''s account id.';


--
-- Name: COLUMN upload.name; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.upload.name IS 'The name of the uploaded file.';


--
-- Name: COLUMN upload.size_byte; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.upload.size_byte IS 'The upload''s size in bytes.';


--
-- Name: COLUMN upload.storage_key; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.upload.storage_key IS 'The upload''s storage key.';


--
-- Name: COLUMN upload.type; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.upload.type IS 'The type of the uploaded file, default is ''image''.';


--
-- Name: upload_create(bigint); Type: FUNCTION; Schema: maevsi; Owner: postgres
--

CREATE FUNCTION maevsi.upload_create(size_byte bigint) RETURNS maevsi.upload
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $_$
DECLARE
    _upload maevsi.upload;
BEGIN
  IF (COALESCE((
    SELECT SUM(upload.size_byte)
    FROM maevsi.upload
    WHERE upload.account_id = current_setting('jwt.claims.account_id')::UUID
  ), 0) + $1 <= (
    SELECT upload_quota_bytes
    FROM maevsi_private.account
    WHERE account.id = current_setting('jwt.claims.account_id')::UUID
  )) THEN
    INSERT INTO maevsi.upload(account_id, size_byte)
    VALUES (current_setting('jwt.claims.account_id')::UUID, $1)
    RETURNING upload.id INTO _upload;

    RETURN _upload;
  ELSE
    RAISE 'Upload quota limit reached!' USING ERRCODE = 'disk_full';
  END IF;
END;
$_$;


ALTER FUNCTION maevsi.upload_create(size_byte bigint) OWNER TO postgres;

--
-- Name: FUNCTION upload_create(size_byte bigint); Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON FUNCTION maevsi.upload_create(size_byte bigint) IS 'Creates an upload with the given size if quota is available.';


--
-- Name: account_email_address_verification_valid_until(); Type: FUNCTION; Schema: maevsi_private; Owner: postgres
--

CREATE FUNCTION maevsi_private.account_email_address_verification_valid_until() RETURNS trigger
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


ALTER FUNCTION maevsi_private.account_email_address_verification_valid_until() OWNER TO postgres;

--
-- Name: FUNCTION account_email_address_verification_valid_until(); Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON FUNCTION maevsi_private.account_email_address_verification_valid_until() IS 'Sets the valid until column of the email address verification to it''s default value.';


--
-- Name: account_password_reset_verification_valid_until(); Type: FUNCTION; Schema: maevsi_private; Owner: postgres
--

CREATE FUNCTION maevsi_private.account_password_reset_verification_valid_until() RETURNS trigger
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


ALTER FUNCTION maevsi_private.account_password_reset_verification_valid_until() OWNER TO postgres;

--
-- Name: FUNCTION account_password_reset_verification_valid_until(); Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON FUNCTION maevsi_private.account_password_reset_verification_valid_until() IS 'Sets the valid until column of the email address verification to it''s default value.';


--
-- Name: events_invited(); Type: FUNCTION; Schema: maevsi_private; Owner: postgres
--

CREATE FUNCTION maevsi_private.events_invited() RETURNS TABLE(event_id uuid)
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
DECLARE
  jwt_account_id UUID;
BEGIN
  jwt_account_id := maevsi.invoker_account_id();

  RETURN QUERY

  -- get all events for invitations
  SELECT invitation.event_id FROM maevsi.invitation
  WHERE
    (
      -- whose invitee
      invitation.contact_id IN (
        SELECT id
        FROM maevsi.contact
        WHERE
            -- is the requesting user
            account_id = jwt_account_id -- if `jwt_account_id` is `NULL` this does *not* return contacts for which `account_id` is NULL (an `IS` instead of `=` comparison would)
          AND
            -- who is not invited by
            author_account_id NOT IN (
              -- a user who the invitee blocked
              SELECT blocked_account_id
              FROM maevsi.account_block
              WHERE author_account_id = jwt_account_id
              UNION ALL
              -- or who has blocked the invitee
              SELECT author_account_id
              FROM maevsi.account_block
              WHERE blocked_account_id = jwt_account_id
            ) -- TODO: it appears blocking should be accounted for after all other criteria using the event author instead
      )
    )
    OR
      -- for which the requesting user knows the id
      invitation.id = ANY (maevsi.invitation_claim_array());
END
$$;


ALTER FUNCTION maevsi_private.events_invited() OWNER TO postgres;

--
-- Name: FUNCTION events_invited(); Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON FUNCTION maevsi_private.events_invited() IS 'Add a function that returns all event ids for which the invoker is invited.';


--
-- Name: account_block_create(uuid, uuid); Type: FUNCTION; Schema: maevsi_test; Owner: postgres
--

CREATE FUNCTION maevsi_test.account_block_create(_author_account_id uuid, _blocked_account_id uuid) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id UUID;
BEGIN
  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _author_account_id || '''';

  INSERT INTO maevsi.account_block(author_account_id, blocked_account_id)
  VALUES (_author_account_id, _blocked_Account_id)
  RETURNING id INTO _id;

  SET LOCAL role = 'postgres';

  RETURN _id;
END $$;


ALTER FUNCTION maevsi_test.account_block_create(_author_account_id uuid, _blocked_account_id uuid) OWNER TO postgres;

--
-- Name: account_block_remove(uuid, uuid); Type: FUNCTION; Schema: maevsi_test; Owner: postgres
--

CREATE FUNCTION maevsi_test.account_block_remove(_author_account_id uuid, _blocked_account_id uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id UUID;
BEGIN
  DELETE FROM maevsi.account_block
  WHERE author_account_id = _author_account_id  and blocked_account_id = _blocked_account_id;
END $$;


ALTER FUNCTION maevsi_test.account_block_remove(_author_account_id uuid, _blocked_account_id uuid) OWNER TO postgres;

--
-- Name: account_create(text, text); Type: FUNCTION; Schema: maevsi_test; Owner: postgres
--

CREATE FUNCTION maevsi_test.account_create(_username text, _email text) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id UUID;
  _verification UUID;
BEGIN
  _id := maevsi.account_registration(_username, _email, 'password', 'en');

  SELECT email_address_verification INTO _verification
  FROM maevsi_private.account
  WHERE id = _id;

  PERFORM maevsi.account_email_address_verification(_verification);

  RETURN _id;
END $$;


ALTER FUNCTION maevsi_test.account_create(_username text, _email text) OWNER TO postgres;

--
-- Name: account_remove(text); Type: FUNCTION; Schema: maevsi_test; Owner: postgres
--

CREATE FUNCTION maevsi_test.account_remove(_username text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id UUID;
BEGIN
  SELECT id INTO _id FROM maevsi.account WHERE username = _username;

  IF _id IS NOT NULL THEN

    SET LOCAL role = 'maevsi_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _id || '''';

    DELETE FROM maevsi.event WHERE author_account_id = _id;

    PERFORM maevsi.account_delete('password');

    SET LOCAL role = 'postgres';
  END IF;
END $$;


ALTER FUNCTION maevsi_test.account_remove(_username text) OWNER TO postgres;

--
-- Name: contact_create(uuid, text); Type: FUNCTION; Schema: maevsi_test; Owner: postgres
--

CREATE FUNCTION maevsi_test.contact_create(_author_account_id uuid, _email_address text) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id UUID;
  _account_id UUID;
BEGIN
  SELECT id FROM maevsi_private.account WHERE email_address = _email_address INTO _account_id;

  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _author_account_id || '''';

  INSERT INTO maevsi.contact(author_account_id, email_address)
  VALUES (_author_account_id, _email_address)
  RETURNING id INTO _id;

  IF (_account_id IS NOT NULL) THEN
    UPDATE maevsi.contact SET account_id = _account_id WHERE id = _id;
  END IF;

  SET LOCAL role = 'postgres';

  RETURN _id;
END $$;


ALTER FUNCTION maevsi_test.contact_create(_author_account_id uuid, _email_address text) OWNER TO postgres;

--
-- Name: contact_select_by_account_id(uuid); Type: FUNCTION; Schema: maevsi_test; Owner: postgres
--

CREATE FUNCTION maevsi_test.contact_select_by_account_id(_account_id uuid) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id UUID;
BEGIN
  SELECT id INTO _id
  FROM maevsi.contact
  WHERE author_account_id = _account_id AND account_id = _account_id;

  RETURN _id;
END $$;


ALTER FUNCTION maevsi_test.contact_select_by_account_id(_account_id uuid) OWNER TO postgres;

--
-- Name: contact_test(text, uuid, uuid[]); Type: FUNCTION; Schema: maevsi_test; Owner: postgres
--

CREATE FUNCTION maevsi_test.contact_test(_test_case text, _account_id uuid, _expected_result uuid[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  rec RECORD;
BEGIN
  IF _account_id IS NULL THEN
    SET LOCAL role = 'maevsi_anonymous';
    SET LOCAL jwt.claims.account_id = '';
  ELSE
    SET LOCAL role = 'maevsi_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';
  END IF;

  IF EXISTS (SELECT id FROM maevsi.contact EXCEPT SELECT * FROM unnest(_expected_result)) THEN
    RAISE EXCEPTION 'some contact should not appear in the query result';
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_result) EXCEPT SELECT id FROM maevsi.contact) THEN
    RAISE EXCEPTION 'some contact is missing in the query result';
  END IF;

  SET LOCAL role = 'postgres';
END $$;


ALTER FUNCTION maevsi_test.contact_test(_test_case text, _account_id uuid, _expected_result uuid[]) OWNER TO postgres;

--
-- Name: event_category_create(text); Type: FUNCTION; Schema: maevsi_test; Owner: postgres
--

CREATE FUNCTION maevsi_test.event_category_create(_category text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO maevsi.event_category(category) VALUES (_category);
END $$;


ALTER FUNCTION maevsi_test.event_category_create(_category text) OWNER TO postgres;

--
-- Name: event_category_mapping_create(uuid, uuid, text); Type: FUNCTION; Schema: maevsi_test; Owner: postgres
--

CREATE FUNCTION maevsi_test.event_category_mapping_create(_author_account_id uuid, _event_id uuid, _category text) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _author_account_id || '''';

  INSERT INTO maevsi.event_category_mapping(event_id, category)
  VALUES (_event_id, _category);

  SET LOCAL role = 'postgres';
END $$;


ALTER FUNCTION maevsi_test.event_category_mapping_create(_author_account_id uuid, _event_id uuid, _category text) OWNER TO postgres;

--
-- Name: event_category_mapping_test(text, uuid, uuid[]); Type: FUNCTION; Schema: maevsi_test; Owner: postgres
--

CREATE FUNCTION maevsi_test.event_category_mapping_test(_test_case text, _account_id uuid, _expected_result uuid[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF _account_id IS NULL THEN
    SET LOCAL role = 'maevsi_anonymous';
    SET LOCAL jwt.claims.account_id = '';
  ELSE
    SET LOCAL role = 'maevsi_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';
  END IF;

  IF EXISTS (SELECT event_id FROM maevsi.event_category_mapping EXCEPT SELECT * FROM unnest(_expected_result)) THEN
    RAISE EXCEPTION 'some event_category_mappings should not appear in the query result';
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_result) EXCEPT SELECT event_id FROM maevsi.event_category_mapping) THEN
    RAISE EXCEPTION 'some event_category_mappings is missing in the query result';
  END IF;

  SET LOCAL role = 'postgres';
END $$;


ALTER FUNCTION maevsi_test.event_category_mapping_test(_test_case text, _account_id uuid, _expected_result uuid[]) OWNER TO postgres;

--
-- Name: event_create(uuid, text, text, text, text); Type: FUNCTION; Schema: maevsi_test; Owner: postgres
--

CREATE FUNCTION maevsi_test.event_create(_author_account_id uuid, _name text, _slug text, _start text, _visibility text) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id UUID;
BEGIN
  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _author_account_id || '''';

  INSERT INTO maevsi.event(author_account_id, name, slug, start, visibility)
  VALUES (_author_account_id, _name, _slug, _start::TIMESTAMP WITH TIME ZONE, _visibility::maevsi.event_visibility)
  RETURNING id INTO _id;

  SET LOCAL role = 'postgres';

  RETURN _id;
END $$;


ALTER FUNCTION maevsi_test.event_create(_author_account_id uuid, _name text, _slug text, _start text, _visibility text) OWNER TO postgres;

--
-- Name: event_test(text, uuid, uuid[]); Type: FUNCTION; Schema: maevsi_test; Owner: postgres
--

CREATE FUNCTION maevsi_test.event_test(_test_case text, _account_id uuid, _expected_result uuid[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF _account_id IS NULL THEN
    SET LOCAL role = 'maevsi_anonymous';
    SET LOCAL jwt.claims.account_id = '';
  ELSE
    SET LOCAL role = 'maevsi_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';
  END IF;

  IF EXISTS (SELECT id FROM maevsi.event EXCEPT SELECT * FROM unnest(_expected_result)) THEN
    RAISE EXCEPTION 'some event should not appear in the query result';
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_result) EXCEPT SELECT id FROM maevsi.event) THEN
    RAISE EXCEPTION 'some event is missing in the query result';
  END IF;

  SET LOCAL role = 'postgres';
END $$;


ALTER FUNCTION maevsi_test.event_test(_test_case text, _account_id uuid, _expected_result uuid[]) OWNER TO postgres;

--
-- Name: invitation_create(uuid, uuid, uuid); Type: FUNCTION; Schema: maevsi_test; Owner: postgres
--

CREATE FUNCTION maevsi_test.invitation_create(_author_account_id uuid, _event_id uuid, _contact_id uuid) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
DECLARE
  _id UUID;
BEGIN
  SET LOCAL role = 'maevsi_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _author_account_id || '''';

  INSERT INTO maevsi.invitation(contact_id, event_id)
  VALUES (_contact_id, _event_id)
  RETURNING id INTO _id;

  SET LOCAL role = 'postgres';

  RETURN _id;
END $$;


ALTER FUNCTION maevsi_test.invitation_create(_author_account_id uuid, _event_id uuid, _contact_id uuid) OWNER TO postgres;

--
-- Name: invitation_test(text, uuid, uuid[]); Type: FUNCTION; Schema: maevsi_test; Owner: postgres
--

CREATE FUNCTION maevsi_test.invitation_test(_test_case text, _account_id uuid, _expected_result uuid[]) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF _account_id IS NULL THEN
    SET LOCAL role = 'maevsi_anonymous';
    SET LOCAL jwt.claims.account_id = '';
  ELSE
    SET LOCAL role = 'maevsi_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';
  END IF;

  IF EXISTS (SELECT id FROM maevsi.invitation EXCEPT SELECT * FROM unnest(_expected_result)) THEN
    RAISE EXCEPTION 'some invitation should not appear in the query result';
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_result) EXCEPT SELECT id FROM maevsi.invitation) THEN
    RAISE EXCEPTION 'some invitation is missing in the query result';
  END IF;

  SET LOCAL role = 'postgres';
END $$;


ALTER FUNCTION maevsi_test.invitation_test(_test_case text, _account_id uuid, _expected_result uuid[]) OWNER TO postgres;

--
-- Name: account; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.account (
    id uuid NOT NULL,
    username text NOT NULL,
    CONSTRAINT account_username_check CHECK (((char_length(username) < 100) AND (username ~ '^[-A-Za-z0-9]+$'::text)))
);


ALTER TABLE maevsi.account OWNER TO postgres;

--
-- Name: TABLE account; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.account IS 'Public account data.';


--
-- Name: COLUMN account.id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.account.id IS 'The account''s internal id.';


--
-- Name: COLUMN account.username; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.account.username IS 'The account''s username.';


--
-- Name: account_block; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.account_block (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    author_account_id uuid NOT NULL,
    blocked_account_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT account_block_check CHECK ((author_account_id <> blocked_account_id))
);


ALTER TABLE maevsi.account_block OWNER TO postgres;

--
-- Name: TABLE account_block; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.account_block IS '@omit update,delete
Blocking of one account by another.';


--
-- Name: COLUMN account_block.id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.account_block.id IS '@omit create\nThe account blocking''s internal id.';


--
-- Name: COLUMN account_block.author_account_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.account_block.author_account_id IS 'The account id of the user who created the blocking.';


--
-- Name: COLUMN account_block.blocked_account_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.account_block.blocked_account_id IS 'The account id of the user who is blocked.';


--
-- Name: COLUMN account_block.created_at; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.account_block.created_at IS '@omit create,update,delete
Timestamp of when the blocking was created.';


--
-- Name: account_interest; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.account_interest (
    account_id uuid NOT NULL,
    category text NOT NULL
);


ALTER TABLE maevsi.account_interest OWNER TO postgres;

--
-- Name: TABLE account_interest; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.account_interest IS 'Event categories a user account is interested in (M:N relationship).';


--
-- Name: COLUMN account_interest.account_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.account_interest.account_id IS 'A user account id.';


--
-- Name: COLUMN account_interest.category; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.account_interest.category IS 'An event category.';


--
-- Name: account_preference_event_size; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.account_preference_event_size (
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    account_id uuid NOT NULL,
    event_size maevsi.event_size NOT NULL
);


ALTER TABLE maevsi.account_preference_event_size OWNER TO postgres;

--
-- Name: TABLE account_preference_event_size; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.account_preference_event_size IS 'Table for the user accounts'' preferred event sizes (M:N relationship).';


--
-- Name: COLUMN account_preference_event_size.created_at; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.account_preference_event_size.created_at IS '@omit create,update
Timestamp of when the event size preference was created, defaults to the current timestamp.';


--
-- Name: COLUMN account_preference_event_size.account_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.account_preference_event_size.account_id IS 'The account''s internal id.';


--
-- Name: COLUMN account_preference_event_size.event_size; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.account_preference_event_size.event_size IS 'A preferred event sized';


--
-- Name: account_social_network; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.account_social_network (
    account_id uuid NOT NULL,
    social_network maevsi.social_network NOT NULL,
    social_network_username text NOT NULL
);


ALTER TABLE maevsi.account_social_network OWNER TO postgres;

--
-- Name: TABLE account_social_network; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.account_social_network IS 'Links accounts to their social media profiles. Each entry represents a specific social network and associated username for an account.';


--
-- Name: COLUMN account_social_network.account_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.account_social_network.account_id IS 'The unique identifier of the account.';


--
-- Name: COLUMN account_social_network.social_network; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.account_social_network.social_network IS 'The social network to which the account is linked.';


--
-- Name: COLUMN account_social_network.social_network_username; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.account_social_network.social_network_username IS 'The username of the account on the specified social network.';


--
-- Name: achievement; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.achievement (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    account_id uuid NOT NULL,
    achievement maevsi.achievement_type NOT NULL,
    level integer DEFAULT 1 NOT NULL,
    CONSTRAINT achievement_level_check CHECK ((level > 0))
);


ALTER TABLE maevsi.achievement OWNER TO postgres;

--
-- Name: TABLE achievement; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.achievement IS 'Achievements unlocked by users.';


--
-- Name: COLUMN achievement.id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.achievement.id IS 'The achievement unlock''s internal id.';


--
-- Name: COLUMN achievement.account_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.achievement.account_id IS 'The account which unlocked the achievement.';


--
-- Name: COLUMN achievement.achievement; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.achievement.achievement IS 'The unlock''s achievement.';


--
-- Name: COLUMN achievement.level; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.achievement.level IS 'The achievement unlock''s level.';


--
-- Name: contact; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.contact (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    account_id uuid,
    address text,
    author_account_id uuid NOT NULL,
    email_address text,
    email_address_hash text GENERATED ALWAYS AS (md5(lower("substring"(email_address, '\S(?:.*\S)*'::text)))) STORED,
    first_name text,
    language maevsi.language,
    last_name text,
    nickname text,
    phone_number text,
    timezone text,
    url text,
    CONSTRAINT contact_address_check CHECK (((char_length(address) > 0) AND (char_length(address) < 300))),
    CONSTRAINT contact_email_address_check CHECK ((char_length(email_address) < 255)),
    CONSTRAINT contact_first_name_check CHECK (((char_length(first_name) > 0) AND (char_length(first_name) < 100))),
    CONSTRAINT contact_last_name_check CHECK (((char_length(last_name) > 0) AND (char_length(last_name) < 100))),
    CONSTRAINT contact_nickname_check CHECK (((char_length(nickname) > 0) AND (char_length(nickname) < 100))),
    CONSTRAINT contact_phone_number_check CHECK ((phone_number ~ '^\+(?:[0-9] ?){6,14}[0-9]$'::text)),
    CONSTRAINT contact_timezone_check CHECK ((timezone ~ '^([+-](0[0-9]|1[0-4]):[0-5][0-9]|Z)$'::text)),
    CONSTRAINT contact_url_check CHECK (((char_length(url) < 300) AND (url ~ '^https:\/\/'::text)))
);


ALTER TABLE maevsi.contact OWNER TO postgres;

--
-- Name: TABLE contact; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.contact IS 'Contact data.';


--
-- Name: COLUMN contact.id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.contact.id IS '@omit create,update
The contact''s internal id.';


--
-- Name: COLUMN contact.created_at; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.contact.created_at IS '@omit create,update
Timestamp of when the contact was created, defaults to the current timestamp.';


--
-- Name: COLUMN contact.account_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.contact.account_id IS 'The contact account''s id.';


--
-- Name: COLUMN contact.address; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.contact.address IS 'The contact''s physical address.';


--
-- Name: COLUMN contact.author_account_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.contact.author_account_id IS 'The contact author''s id.';


--
-- Name: COLUMN contact.email_address; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.contact.email_address IS 'The contact''s email address.';


--
-- Name: COLUMN contact.email_address_hash; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.contact.email_address_hash IS '@omit create,update
The contact''s email address''s md5 hash.';


--
-- Name: COLUMN contact.first_name; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.contact.first_name IS 'The contact''s first name.';


--
-- Name: COLUMN contact.language; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.contact.language IS 'The contact''s language.';


--
-- Name: COLUMN contact.last_name; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.contact.last_name IS 'The contact''s last name.';


--
-- Name: COLUMN contact.nickname; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.contact.nickname IS 'The contact''s nickname.';


--
-- Name: COLUMN contact.phone_number; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.contact.phone_number IS 'The contact''s international phone number in E.164 format (https://wikipedia.org/wiki/E.164).';


--
-- Name: COLUMN contact.timezone; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.contact.timezone IS 'The contact''s ISO 8601 timezone, e.g. `+02:00`, `-05:30` or `Z`.';


--
-- Name: COLUMN contact.url; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.contact.url IS 'The contact''s website url.';


--
-- Name: event_category; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.event_category (
    category text NOT NULL
);


ALTER TABLE maevsi.event_category OWNER TO postgres;

--
-- Name: TABLE event_category; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.event_category IS 'Event categories.';


--
-- Name: COLUMN event_category.category; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_category.category IS 'A category name.';


--
-- Name: event_category_mapping; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.event_category_mapping (
    event_id uuid NOT NULL,
    category text NOT NULL
);


ALTER TABLE maevsi.event_category_mapping OWNER TO postgres;

--
-- Name: TABLE event_category_mapping; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.event_category_mapping IS 'Mapping events to categories (M:N relationship).';


--
-- Name: COLUMN event_category_mapping.event_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_category_mapping.event_id IS 'An event id.';


--
-- Name: COLUMN event_category_mapping.category; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_category_mapping.category IS 'A category name.';


--
-- Name: event_favourite; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.event_favourite (
    account_id uuid NOT NULL,
    event_id uuid NOT NULL
);


ALTER TABLE maevsi.event_favourite OWNER TO postgres;

--
-- Name: TABLE event_favourite; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.event_favourite IS 'The user accounts'' favourite events.';


--
-- Name: COLUMN event_favourite.account_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_favourite.account_id IS 'A user account id.';


--
-- Name: COLUMN event_favourite.event_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_favourite.event_id IS 'The ID of an event which the user marked as a favourite.';


--
-- Name: event_group; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.event_group (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    author_account_id uuid NOT NULL,
    description text,
    is_archived boolean DEFAULT false NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    CONSTRAINT event_group_description_check CHECK ((char_length(description) < 1000000)),
    CONSTRAINT event_group_name_check CHECK (((char_length(name) > 0) AND (char_length(name) < 100))),
    CONSTRAINT event_group_slug_check CHECK (((char_length(slug) < 100) AND (slug ~ '^[-A-Za-z0-9]+$'::text)))
);


ALTER TABLE maevsi.event_group OWNER TO postgres;

--
-- Name: TABLE event_group; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.event_group IS 'A group of events.';


--
-- Name: COLUMN event_group.id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_group.id IS '@omit create,update
The event group''s internal id.';


--
-- Name: COLUMN event_group.created_at; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_group.created_at IS '@omit create,update
Timestamp of when the event group was created, defaults to the current timestamp.';


--
-- Name: COLUMN event_group.author_account_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_group.author_account_id IS 'The event group author''s id.';


--
-- Name: COLUMN event_group.description; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_group.description IS 'The event group''s description.';


--
-- Name: COLUMN event_group.is_archived; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_group.is_archived IS 'Indicates whether the event group is archived.';


--
-- Name: COLUMN event_group.name; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_group.name IS 'The event group''s name.';


--
-- Name: COLUMN event_group.slug; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_group.slug IS '@omit create,update
The event group''s name, slugified.';


--
-- Name: event_grouping; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.event_grouping (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_group_id uuid NOT NULL,
    event_id uuid NOT NULL
);


ALTER TABLE maevsi.event_grouping OWNER TO postgres;

--
-- Name: TABLE event_grouping; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.event_grouping IS 'A bidirectional mapping between an event and an event group.';


--
-- Name: COLUMN event_grouping.id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_grouping.id IS '@omit create,update
The event grouping''s internal id.';


--
-- Name: COLUMN event_grouping.event_group_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_grouping.event_group_id IS 'The event grouping''s internal event group id.';


--
-- Name: COLUMN event_grouping.event_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_grouping.event_id IS 'The event grouping''s internal event id.';


--
-- Name: event_recommendation; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.event_recommendation (
    account_id uuid NOT NULL,
    event_id uuid NOT NULL,
    score real,
    predicted_score real
);


ALTER TABLE maevsi.event_recommendation OWNER TO postgres;

--
-- Name: TABLE event_recommendation; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.event_recommendation IS 'Events recommended to a user account (M:N relationship).';


--
-- Name: COLUMN event_recommendation.account_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_recommendation.account_id IS 'A user account id.';


--
-- Name: COLUMN event_recommendation.event_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_recommendation.event_id IS 'The predicted score of the recommendation.';


--
-- Name: COLUMN event_recommendation.score; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_recommendation.score IS 'An event id.';


--
-- Name: COLUMN event_recommendation.predicted_score; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_recommendation.predicted_score IS 'The score of the recommendation.';


--
-- Name: event_upload; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.event_upload (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid NOT NULL,
    upload_id uuid NOT NULL
);


ALTER TABLE maevsi.event_upload OWNER TO postgres;

--
-- Name: TABLE event_upload; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.event_upload IS 'An assignment of an uploaded content (e.g. an image) to an event.';


--
-- Name: COLUMN event_upload.id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_upload.id IS '@omit create,update
The event''s internal id for which the invitation is valid.';


--
-- Name: COLUMN event_upload.event_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_upload.event_id IS '@omit update
The event''s internal id for which the invitation is valid.';


--
-- Name: COLUMN event_upload.upload_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.event_upload.upload_id IS '@omit update
The internal id of the uploaded content.';


--
-- Name: invitation; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.invitation (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone,
    updated_by uuid,
    contact_id uuid NOT NULL,
    event_id uuid NOT NULL,
    feedback maevsi.invitation_feedback,
    feedback_paper maevsi.invitation_feedback_paper
);


ALTER TABLE maevsi.invitation OWNER TO postgres;

--
-- Name: TABLE invitation; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.invitation IS 'An invitation for a contact. A bidirectional mapping between an event and a contact.';


--
-- Name: COLUMN invitation.id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.invitation.id IS '@omit create,update
The invitations''s internal id.';


--
-- Name: COLUMN invitation.created_at; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.invitation.created_at IS '@omit create,update
Timestamp of when the invitation was created, defaults to the current timestamp.';


--
-- Name: COLUMN invitation.updated_at; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.invitation.updated_at IS '@omit create,update
Timestamp of when the invitation was last updated.';


--
-- Name: COLUMN invitation.updated_by; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.invitation.updated_by IS '@omit create,update
The id of the account which last updated the invitation. `NULL` if the invitation was updated by an anonymous user.';


--
-- Name: COLUMN invitation.contact_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.invitation.contact_id IS 'The contact''s internal id for which the invitation is valid.';


--
-- Name: COLUMN invitation.event_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.invitation.event_id IS 'The event''s internal id for which the invitation is valid.';


--
-- Name: COLUMN invitation.feedback; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.invitation.feedback IS 'The invitation''s general feedback status.';


--
-- Name: COLUMN invitation.feedback_paper; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.invitation.feedback_paper IS 'The invitation''s paper feedback status.';


--
-- Name: invitation_flat; Type: VIEW; Schema: maevsi; Owner: postgres
--

CREATE VIEW maevsi.invitation_flat WITH (security_invoker='true') AS
 SELECT invitation.id AS invitation_id,
    invitation.contact_id AS invitation_contact_id,
    invitation.event_id AS invitation_event_id,
    invitation.feedback AS invitation_feedback,
    invitation.feedback_paper AS invitation_feedback_paper,
    contact.id AS contact_id,
    contact.account_id AS contact_account_id,
    contact.address AS contact_address,
    contact.author_account_id AS contact_author_account_id,
    contact.email_address AS contact_email_address,
    contact.email_address_hash AS contact_email_address_hash,
    contact.first_name AS contact_first_name,
    contact.last_name AS contact_last_name,
    contact.phone_number AS contact_phone_number,
    contact.url AS contact_url,
    event.id AS event_id,
    event.author_account_id AS event_author_account_id,
    event.description AS event_description,
    event.start AS event_start,
    event."end" AS event_end,
    event.invitee_count_maximum AS event_invitee_count_maximum,
    event.is_archived AS event_is_archived,
    event.is_in_person AS event_is_in_person,
    event.is_remote AS event_is_remote,
    event.location AS event_location,
    event.name AS event_name,
    event.slug AS event_slug,
    event.url AS event_url,
    event.visibility AS event_visibility
   FROM ((maevsi.invitation
     JOIN maevsi.contact ON ((invitation.contact_id = contact.id)))
     JOIN maevsi.event ON ((invitation.event_id = event.id)));


ALTER VIEW maevsi.invitation_flat OWNER TO postgres;

--
-- Name: VIEW invitation_flat; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON VIEW maevsi.invitation_flat IS 'View returning flattened invitations.';


--
-- Name: legal_term; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.legal_term (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    language character varying(5) DEFAULT 'en'::character varying NOT NULL,
    term text NOT NULL,
    version character varying(20) NOT NULL,
    CONSTRAINT legal_term_language_check CHECK (((language)::text ~ '^[a-z]{2}(_[A-Z]{2})?$'::text)),
    CONSTRAINT legal_term_term_check CHECK (((char_length(term) > 0) AND (char_length(term) <= 500000))),
    CONSTRAINT legal_term_version_check CHECK (((version)::text ~ '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$'::text))
);


ALTER TABLE maevsi.legal_term OWNER TO postgres;

--
-- Name: TABLE legal_term; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.legal_term IS '@omit create,update,delete
Legal terms like privacy policies or terms of service.';


--
-- Name: COLUMN legal_term.id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.legal_term.id IS 'Unique identifier for each legal term.';


--
-- Name: COLUMN legal_term.created_at; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.legal_term.created_at IS 'Timestamp when the term was created. Set to the current time by default.';


--
-- Name: COLUMN legal_term.language; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.legal_term.language IS 'Language code in ISO 639-1 format with optional region (e.g., `en` for English, `en_GB` for British English)';


--
-- Name: COLUMN legal_term.term; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.legal_term.term IS 'Text of the legal term. Markdown is expected to be used. It must be non-empty and cannot exceed 500,000 characters.';


--
-- Name: COLUMN legal_term.version; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.legal_term.version IS 'Semantic versioning string to track changes to the legal terms (format: `X.Y.Z`).';


--
-- Name: legal_term_acceptance; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.legal_term_acceptance (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    account_id uuid NOT NULL,
    legal_term_id uuid NOT NULL
);


ALTER TABLE maevsi.legal_term_acceptance OWNER TO postgres;

--
-- Name: TABLE legal_term_acceptance; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.legal_term_acceptance IS '@omit update,delete\nTracks each user account''s acceptance of legal terms and conditions.';


--
-- Name: COLUMN legal_term_acceptance.id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.legal_term_acceptance.id IS '@omit create
Unique identifier for this legal term acceptance record. Automatically generated for each new acceptance.';


--
-- Name: COLUMN legal_term_acceptance.created_at; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.legal_term_acceptance.created_at IS '@omit create
Timestamp showing when the legal terms were accepted, set automatically at the time of acceptance.';


--
-- Name: COLUMN legal_term_acceptance.account_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.legal_term_acceptance.account_id IS 'The user account ID that accepted the legal terms. If the account is deleted, this acceptance record will also be deleted.';


--
-- Name: COLUMN legal_term_acceptance.legal_term_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.legal_term_acceptance.legal_term_id IS 'The ID of the legal terms that were accepted. Deletion of these legal terms is restricted while they are still referenced in this table.';


--
-- Name: profile_picture; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.profile_picture (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    account_id uuid NOT NULL,
    upload_id uuid NOT NULL
);


ALTER TABLE maevsi.profile_picture OWNER TO postgres;

--
-- Name: TABLE profile_picture; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.profile_picture IS 'Mapping of account ids to upload ids.';


--
-- Name: COLUMN profile_picture.id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.profile_picture.id IS '@omit create,update
The profile picture''s internal id.';


--
-- Name: COLUMN profile_picture.account_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.profile_picture.account_id IS 'The account''s id.';


--
-- Name: COLUMN profile_picture.upload_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.profile_picture.upload_id IS 'The upload''s id.';


--
-- Name: report; Type: TABLE; Schema: maevsi; Owner: postgres
--

CREATE TABLE maevsi.report (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    author_account_id uuid NOT NULL,
    reason text NOT NULL,
    target_account_id uuid,
    target_event_id uuid,
    target_upload_id uuid,
    CONSTRAINT report_check CHECK ((num_nonnulls(target_account_id, target_event_id, target_upload_id) = 1)),
    CONSTRAINT report_reason_check CHECK (((char_length(reason) > 0) AND (char_length(reason) < 2000)))
);


ALTER TABLE maevsi.report OWNER TO postgres;

--
-- Name: TABLE report; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON TABLE maevsi.report IS '@omit update,delete
Stores reports made by users on other users, events, or uploads for moderation purposes.';


--
-- Name: COLUMN report.id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.report.id IS '@omit create
Unique identifier for the report, generated randomly using UUIDs.';


--
-- Name: COLUMN report.created_at; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.report.created_at IS '@omit create
Timestamp of when the report was created, defaults to the current timestamp.';


--
-- Name: COLUMN report.author_account_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.report.author_account_id IS 'The ID of the user who created the report.';


--
-- Name: COLUMN report.reason; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.report.reason IS 'The reason for the report, provided by the reporting user. Must be non-empty and less than 2000 characters.';


--
-- Name: COLUMN report.target_account_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.report.target_account_id IS 'The ID of the account being reported, if applicable.';


--
-- Name: COLUMN report.target_event_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.report.target_event_id IS 'The ID of the event being reported, if applicable.';


--
-- Name: COLUMN report.target_upload_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON COLUMN maevsi.report.target_upload_id IS 'The ID of the upload being reported, if applicable.';


--
-- Name: CONSTRAINT report_check ON report; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON CONSTRAINT report_check ON maevsi.report IS 'Ensures that the report targets exactly one element (account, event, or upload).';


--
-- Name: CONSTRAINT report_reason_check ON report; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON CONSTRAINT report_reason_check ON maevsi.report IS 'Ensures the reason field contains between 1 and 2000 characters.';


--
-- Name: account; Type: TABLE; Schema: maevsi_private; Owner: postgres
--

CREATE TABLE maevsi_private.account (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    birth_date date,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    email_address text NOT NULL,
    email_address_verification uuid DEFAULT gen_random_uuid(),
    email_address_verification_valid_until timestamp with time zone,
    last_activity timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    location maevsi.geometry(Point,4839),
    password_hash text NOT NULL,
    password_reset_verification uuid,
    password_reset_verification_valid_until timestamp with time zone,
    upload_quota_bytes bigint DEFAULT 10485760 NOT NULL,
    CONSTRAINT account_email_address_check CHECK ((char_length(email_address) < 255))
);


ALTER TABLE maevsi_private.account OWNER TO postgres;

--
-- Name: TABLE account; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON TABLE maevsi_private.account IS 'Private account data.';


--
-- Name: COLUMN account.id; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.account.id IS 'The account''s internal id.';


--
-- Name: COLUMN account.birth_date; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.account.birth_date IS 'The account owner''s date of birth.';


--
-- Name: COLUMN account.created_at; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.account.created_at IS 'Timestamp at which the account was last active.';


--
-- Name: COLUMN account.email_address; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.account.email_address IS 'The account''s email address for account related information.';


--
-- Name: COLUMN account.email_address_verification; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.account.email_address_verification IS 'The UUID used to verify an email address, or null if already verified.';


--
-- Name: COLUMN account.email_address_verification_valid_until; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.account.email_address_verification_valid_until IS 'The timestamp until which an email address verification is valid.';


--
-- Name: COLUMN account.last_activity; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.account.last_activity IS 'Timestamp at which the account last requested an access token.';


--
-- Name: COLUMN account.location; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.account.location IS 'The account''s geometric location.';


--
-- Name: COLUMN account.password_hash; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.account.password_hash IS 'The account''s password, hashed and salted.';


--
-- Name: COLUMN account.password_reset_verification; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.account.password_reset_verification IS 'The UUID used to reset a password, or null if there is no pending reset request.';


--
-- Name: COLUMN account.password_reset_verification_valid_until; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.account.password_reset_verification_valid_until IS 'The timestamp until which a password reset is valid.';


--
-- Name: COLUMN account.upload_quota_bytes; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.account.upload_quota_bytes IS 'The account''s upload quota in bytes.';


--
-- Name: achievement_code; Type: TABLE; Schema: maevsi_private; Owner: postgres
--

CREATE TABLE maevsi_private.achievement_code (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    alias text NOT NULL,
    achievement maevsi.achievement_type NOT NULL,
    CONSTRAINT achievement_code_alias_check CHECK ((char_length(alias) < 1000))
);


ALTER TABLE maevsi_private.achievement_code OWNER TO postgres;

--
-- Name: TABLE achievement_code; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON TABLE maevsi_private.achievement_code IS 'Codes that unlock achievements.';


--
-- Name: COLUMN achievement_code.id; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.achievement_code.id IS 'The code that unlocks an achievement.';


--
-- Name: COLUMN achievement_code.alias; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.achievement_code.alias IS 'An alternative code, e.g. human readable, that unlocks an achievement.';


--
-- Name: COLUMN achievement_code.achievement; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.achievement_code.achievement IS 'The achievement that is unlocked by the code.';


--
-- Name: jwt; Type: TABLE; Schema: maevsi_private; Owner: postgres
--

CREATE TABLE maevsi_private.jwt (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    token maevsi.jwt NOT NULL
);


ALTER TABLE maevsi_private.jwt OWNER TO postgres;

--
-- Name: TABLE jwt; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON TABLE maevsi_private.jwt IS 'A list of tokens.';


--
-- Name: COLUMN jwt.id; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.jwt.id IS 'The token''s id.';


--
-- Name: COLUMN jwt.token; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.jwt.token IS 'The token.';


--
-- Name: notification; Type: TABLE; Schema: maevsi_private; Owner: postgres
--

CREATE TABLE maevsi_private.notification (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    channel text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_acknowledged boolean,
    payload text NOT NULL,
    CONSTRAINT notification_payload_check CHECK ((octet_length(payload) <= 8000))
);


ALTER TABLE maevsi_private.notification OWNER TO postgres;

--
-- Name: TABLE notification; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON TABLE maevsi_private.notification IS 'A notification.';


--
-- Name: COLUMN notification.id; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.notification.id IS 'The notification''s internal id.';


--
-- Name: COLUMN notification.channel; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.notification.channel IS 'The notification''s channel.';


--
-- Name: COLUMN notification.created_at; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.notification.created_at IS 'The timestamp of the notification''s creation.';


--
-- Name: COLUMN notification.is_acknowledged; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.notification.is_acknowledged IS 'Whether the notification was acknowledged.';


--
-- Name: COLUMN notification.payload; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON COLUMN maevsi_private.notification.payload IS 'The notification''s payload.';


--
-- Name: changes; Type: TABLE; Schema: sqitch; Owner: postgres
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


ALTER TABLE sqitch.changes OWNER TO postgres;

--
-- Name: TABLE changes; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON TABLE sqitch.changes IS 'Tracks the changes currently deployed to the database.';


--
-- Name: COLUMN changes.change_id; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.changes.change_id IS 'Change primary key.';


--
-- Name: COLUMN changes.script_hash; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.changes.script_hash IS 'Deploy script SHA-1 hash.';


--
-- Name: COLUMN changes.change; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.changes.change IS 'Name of a deployed change.';


--
-- Name: COLUMN changes.project; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.changes.project IS 'Name of the Sqitch project to which the change belongs.';


--
-- Name: COLUMN changes.note; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.changes.note IS 'Description of the change.';


--
-- Name: COLUMN changes.committed_at; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.changes.committed_at IS 'Date the change was deployed.';


--
-- Name: COLUMN changes.committer_name; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.changes.committer_name IS 'Name of the user who deployed the change.';


--
-- Name: COLUMN changes.committer_email; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.changes.committer_email IS 'Email address of the user who deployed the change.';


--
-- Name: COLUMN changes.planned_at; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.changes.planned_at IS 'Date the change was added to the plan.';


--
-- Name: COLUMN changes.planner_name; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.changes.planner_name IS 'Name of the user who planed the change.';


--
-- Name: COLUMN changes.planner_email; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.changes.planner_email IS 'Email address of the user who planned the change.';


--
-- Name: dependencies; Type: TABLE; Schema: sqitch; Owner: postgres
--

CREATE TABLE sqitch.dependencies (
    change_id text NOT NULL,
    type text NOT NULL,
    dependency text NOT NULL,
    dependency_id text,
    CONSTRAINT dependencies_check CHECK ((((type = 'require'::text) AND (dependency_id IS NOT NULL)) OR ((type = 'conflict'::text) AND (dependency_id IS NULL))))
);


ALTER TABLE sqitch.dependencies OWNER TO postgres;

--
-- Name: TABLE dependencies; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON TABLE sqitch.dependencies IS 'Tracks the currently satisfied dependencies.';


--
-- Name: COLUMN dependencies.change_id; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.dependencies.change_id IS 'ID of the depending change.';


--
-- Name: COLUMN dependencies.type; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.dependencies.type IS 'Type of dependency.';


--
-- Name: COLUMN dependencies.dependency; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.dependencies.dependency IS 'Dependency name.';


--
-- Name: COLUMN dependencies.dependency_id; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.dependencies.dependency_id IS 'Change ID the dependency resolves to.';


--
-- Name: events; Type: TABLE; Schema: sqitch; Owner: postgres
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


ALTER TABLE sqitch.events OWNER TO postgres;

--
-- Name: TABLE events; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON TABLE sqitch.events IS 'Contains full history of all deployment events.';


--
-- Name: COLUMN events.event; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.events.event IS 'Type of event.';


--
-- Name: COLUMN events.change_id; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.events.change_id IS 'Change ID.';


--
-- Name: COLUMN events.change; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.events.change IS 'Change name.';


--
-- Name: COLUMN events.project; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.events.project IS 'Name of the Sqitch project to which the change belongs.';


--
-- Name: COLUMN events.note; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.events.note IS 'Description of the change.';


--
-- Name: COLUMN events.requires; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.events.requires IS 'Array of the names of required changes.';


--
-- Name: COLUMN events.conflicts; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.events.conflicts IS 'Array of the names of conflicting changes.';


--
-- Name: COLUMN events.tags; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.events.tags IS 'Tags associated with the change.';


--
-- Name: COLUMN events.committed_at; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.events.committed_at IS 'Date the event was committed.';


--
-- Name: COLUMN events.committer_name; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.events.committer_name IS 'Name of the user who committed the event.';


--
-- Name: COLUMN events.committer_email; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.events.committer_email IS 'Email address of the user who committed the event.';


--
-- Name: COLUMN events.planned_at; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.events.planned_at IS 'Date the event was added to the plan.';


--
-- Name: COLUMN events.planner_name; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.events.planner_name IS 'Name of the user who planed the change.';


--
-- Name: COLUMN events.planner_email; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.events.planner_email IS 'Email address of the user who plan planned the change.';


--
-- Name: projects; Type: TABLE; Schema: sqitch; Owner: postgres
--

CREATE TABLE sqitch.projects (
    project text NOT NULL,
    uri text,
    created_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    creator_name text NOT NULL,
    creator_email text NOT NULL
);


ALTER TABLE sqitch.projects OWNER TO postgres;

--
-- Name: TABLE projects; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON TABLE sqitch.projects IS 'Sqitch projects deployed to this database.';


--
-- Name: COLUMN projects.project; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.projects.project IS 'Unique Name of a project.';


--
-- Name: COLUMN projects.uri; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.projects.uri IS 'Optional project URI';


--
-- Name: COLUMN projects.created_at; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.projects.created_at IS 'Date the project was added to the database.';


--
-- Name: COLUMN projects.creator_name; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.projects.creator_name IS 'Name of the user who added the project.';


--
-- Name: COLUMN projects.creator_email; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.projects.creator_email IS 'Email address of the user who added the project.';


--
-- Name: releases; Type: TABLE; Schema: sqitch; Owner: postgres
--

CREATE TABLE sqitch.releases (
    version real NOT NULL,
    installed_at timestamp with time zone DEFAULT clock_timestamp() NOT NULL,
    installer_name text NOT NULL,
    installer_email text NOT NULL
);


ALTER TABLE sqitch.releases OWNER TO postgres;

--
-- Name: TABLE releases; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON TABLE sqitch.releases IS 'Sqitch registry releases.';


--
-- Name: COLUMN releases.version; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.releases.version IS 'Version of the Sqitch registry.';


--
-- Name: COLUMN releases.installed_at; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.releases.installed_at IS 'Date the registry release was installed.';


--
-- Name: COLUMN releases.installer_name; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.releases.installer_name IS 'Name of the user who installed the registry release.';


--
-- Name: COLUMN releases.installer_email; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.releases.installer_email IS 'Email address of the user who installed the registry release.';


--
-- Name: tags; Type: TABLE; Schema: sqitch; Owner: postgres
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


ALTER TABLE sqitch.tags OWNER TO postgres;

--
-- Name: TABLE tags; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON TABLE sqitch.tags IS 'Tracks the tags currently applied to the database.';


--
-- Name: COLUMN tags.tag_id; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.tags.tag_id IS 'Tag primary key.';


--
-- Name: COLUMN tags.tag; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.tags.tag IS 'Project-unique tag name.';


--
-- Name: COLUMN tags.project; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.tags.project IS 'Name of the Sqitch project to which the tag belongs.';


--
-- Name: COLUMN tags.change_id; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.tags.change_id IS 'ID of last change deployed before the tag was applied.';


--
-- Name: COLUMN tags.note; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.tags.note IS 'Description of the tag.';


--
-- Name: COLUMN tags.committed_at; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.tags.committed_at IS 'Date the tag was applied to the database.';


--
-- Name: COLUMN tags.committer_name; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.tags.committer_name IS 'Name of the user who applied the tag.';


--
-- Name: COLUMN tags.committer_email; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.tags.committer_email IS 'Email address of the user who applied the tag.';


--
-- Name: COLUMN tags.planned_at; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.tags.planned_at IS 'Date the tag was added to the plan.';


--
-- Name: COLUMN tags.planner_name; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.tags.planner_name IS 'Name of the user who planed the tag.';


--
-- Name: COLUMN tags.planner_email; Type: COMMENT; Schema: sqitch; Owner: postgres
--

COMMENT ON COLUMN sqitch.tags.planner_email IS 'Email address of the user who planned the tag.';


--
-- Name: account_block account_block_author_account_id_blocked_account_id_key; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.account_block
    ADD CONSTRAINT account_block_author_account_id_blocked_account_id_key UNIQUE (author_account_id, blocked_account_id);


--
-- Name: account_block account_block_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.account_block
    ADD CONSTRAINT account_block_pkey PRIMARY KEY (id);


--
-- Name: account_interest account_interest_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.account_interest
    ADD CONSTRAINT account_interest_pkey PRIMARY KEY (account_id, category);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: account_preference_event_size account_preference_event_size_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.account_preference_event_size
    ADD CONSTRAINT account_preference_event_size_pkey PRIMARY KEY (account_id, event_size);


--
-- Name: account_social_network account_social_network_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.account_social_network
    ADD CONSTRAINT account_social_network_pkey PRIMARY KEY (account_id, social_network);


--
-- Name: CONSTRAINT account_social_network_pkey ON account_social_network; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON CONSTRAINT account_social_network_pkey ON maevsi.account_social_network IS 'Ensures uniqueness by combining the account ID and social network, allowing each account to have a single entry per social network.';


--
-- Name: account account_username_key; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.account
    ADD CONSTRAINT account_username_key UNIQUE (username);


--
-- Name: achievement achievement_account_id_achievement_key; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.achievement
    ADD CONSTRAINT achievement_account_id_achievement_key UNIQUE (account_id, achievement);


--
-- Name: achievement achievement_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.achievement
    ADD CONSTRAINT achievement_pkey PRIMARY KEY (id);


--
-- Name: contact contact_author_account_id_account_id_key; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.contact
    ADD CONSTRAINT contact_author_account_id_account_id_key UNIQUE (author_account_id, account_id);


--
-- Name: contact contact_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.contact
    ADD CONSTRAINT contact_pkey PRIMARY KEY (id);


--
-- Name: event event_author_account_id_slug_key; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event
    ADD CONSTRAINT event_author_account_id_slug_key UNIQUE (author_account_id, slug);


--
-- Name: event_category_mapping event_category_mapping_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_category_mapping
    ADD CONSTRAINT event_category_mapping_pkey PRIMARY KEY (event_id, category);


--
-- Name: event_category event_category_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_category
    ADD CONSTRAINT event_category_pkey PRIMARY KEY (category);


--
-- Name: event_favourite event_favourite_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_favourite
    ADD CONSTRAINT event_favourite_pkey PRIMARY KEY (account_id, event_id);


--
-- Name: event_group event_group_author_account_id_slug_key; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_group
    ADD CONSTRAINT event_group_author_account_id_slug_key UNIQUE (author_account_id, slug);


--
-- Name: event_group event_group_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_group
    ADD CONSTRAINT event_group_pkey PRIMARY KEY (id);


--
-- Name: event_grouping event_grouping_event_id_event_group_id_key; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_grouping
    ADD CONSTRAINT event_grouping_event_id_event_group_id_key UNIQUE (event_id, event_group_id);


--
-- Name: event_grouping event_grouping_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_grouping
    ADD CONSTRAINT event_grouping_pkey PRIMARY KEY (id);


--
-- Name: event event_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);


--
-- Name: event_recommendation event_recommendation_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_recommendation
    ADD CONSTRAINT event_recommendation_pkey PRIMARY KEY (account_id, event_id);


--
-- Name: event_upload event_upload_event_id_upload_id_key; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_upload
    ADD CONSTRAINT event_upload_event_id_upload_id_key UNIQUE (event_id, upload_id);


--
-- Name: event_upload event_upload_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_upload
    ADD CONSTRAINT event_upload_pkey PRIMARY KEY (id);


--
-- Name: invitation invitation_event_id_contact_id_key; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.invitation
    ADD CONSTRAINT invitation_event_id_contact_id_key UNIQUE (event_id, contact_id);


--
-- Name: invitation invitation_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.invitation
    ADD CONSTRAINT invitation_pkey PRIMARY KEY (id);


--
-- Name: legal_term_acceptance legal_term_acceptance_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.legal_term_acceptance
    ADD CONSTRAINT legal_term_acceptance_pkey PRIMARY KEY (id);


--
-- Name: legal_term legal_term_language_version_key; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.legal_term
    ADD CONSTRAINT legal_term_language_version_key UNIQUE (language, version);


--
-- Name: legal_term legal_term_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.legal_term
    ADD CONSTRAINT legal_term_pkey PRIMARY KEY (id);


--
-- Name: profile_picture profile_picture_account_id_key; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.profile_picture
    ADD CONSTRAINT profile_picture_account_id_key UNIQUE (account_id);


--
-- Name: profile_picture profile_picture_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.profile_picture
    ADD CONSTRAINT profile_picture_pkey PRIMARY KEY (id);


--
-- Name: report report_author_account_id_target_account_id_target_event_id__key; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.report
    ADD CONSTRAINT report_author_account_id_target_account_id_target_event_id__key UNIQUE (author_account_id, target_account_id, target_event_id, target_upload_id);


--
-- Name: CONSTRAINT report_author_account_id_target_account_id_target_event_id__key ON report; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON CONSTRAINT report_author_account_id_target_account_id_target_event_id__key ON maevsi.report IS 'Ensures that the same user cannot submit multiple reports on the same element (account, event, or upload).';


--
-- Name: report report_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.report
    ADD CONSTRAINT report_pkey PRIMARY KEY (id);


--
-- Name: upload upload_pkey; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.upload
    ADD CONSTRAINT upload_pkey PRIMARY KEY (id);


--
-- Name: upload upload_storage_key_key; Type: CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.upload
    ADD CONSTRAINT upload_storage_key_key UNIQUE (storage_key);


--
-- Name: account account_email_address_key; Type: CONSTRAINT; Schema: maevsi_private; Owner: postgres
--

ALTER TABLE ONLY maevsi_private.account
    ADD CONSTRAINT account_email_address_key UNIQUE (email_address);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: maevsi_private; Owner: postgres
--

ALTER TABLE ONLY maevsi_private.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: achievement_code achievement_code_alias_key; Type: CONSTRAINT; Schema: maevsi_private; Owner: postgres
--

ALTER TABLE ONLY maevsi_private.achievement_code
    ADD CONSTRAINT achievement_code_alias_key UNIQUE (alias);


--
-- Name: achievement_code achievement_code_pkey; Type: CONSTRAINT; Schema: maevsi_private; Owner: postgres
--

ALTER TABLE ONLY maevsi_private.achievement_code
    ADD CONSTRAINT achievement_code_pkey PRIMARY KEY (id);


--
-- Name: jwt jwt_pkey; Type: CONSTRAINT; Schema: maevsi_private; Owner: postgres
--

ALTER TABLE ONLY maevsi_private.jwt
    ADD CONSTRAINT jwt_pkey PRIMARY KEY (id);


--
-- Name: jwt jwt_token_key; Type: CONSTRAINT; Schema: maevsi_private; Owner: postgres
--

ALTER TABLE ONLY maevsi_private.jwt
    ADD CONSTRAINT jwt_token_key UNIQUE (token);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: maevsi_private; Owner: postgres
--

ALTER TABLE ONLY maevsi_private.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: changes changes_pkey; Type: CONSTRAINT; Schema: sqitch; Owner: postgres
--

ALTER TABLE ONLY sqitch.changes
    ADD CONSTRAINT changes_pkey PRIMARY KEY (change_id);


--
-- Name: changes changes_project_script_hash_key; Type: CONSTRAINT; Schema: sqitch; Owner: postgres
--

ALTER TABLE ONLY sqitch.changes
    ADD CONSTRAINT changes_project_script_hash_key UNIQUE (project, script_hash);


--
-- Name: dependencies dependencies_pkey; Type: CONSTRAINT; Schema: sqitch; Owner: postgres
--

ALTER TABLE ONLY sqitch.dependencies
    ADD CONSTRAINT dependencies_pkey PRIMARY KEY (change_id, dependency);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: sqitch; Owner: postgres
--

ALTER TABLE ONLY sqitch.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (change_id, committed_at);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: sqitch; Owner: postgres
--

ALTER TABLE ONLY sqitch.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (project);


--
-- Name: projects projects_uri_key; Type: CONSTRAINT; Schema: sqitch; Owner: postgres
--

ALTER TABLE ONLY sqitch.projects
    ADD CONSTRAINT projects_uri_key UNIQUE (uri);


--
-- Name: releases releases_pkey; Type: CONSTRAINT; Schema: sqitch; Owner: postgres
--

ALTER TABLE ONLY sqitch.releases
    ADD CONSTRAINT releases_pkey PRIMARY KEY (version);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: sqitch; Owner: postgres
--

ALTER TABLE ONLY sqitch.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (tag_id);


--
-- Name: tags tags_project_tag_key; Type: CONSTRAINT; Schema: sqitch; Owner: postgres
--

ALTER TABLE ONLY sqitch.tags
    ADD CONSTRAINT tags_project_tag_key UNIQUE (project, tag);


--
-- Name: idx_event_author_account_id; Type: INDEX; Schema: maevsi; Owner: postgres
--

CREATE INDEX idx_event_author_account_id ON maevsi.event USING btree (author_account_id);


--
-- Name: INDEX idx_event_author_account_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON INDEX maevsi.idx_event_author_account_id IS 'Speeds up reverse foreign key lookups.';


--
-- Name: idx_event_group_author_account_id; Type: INDEX; Schema: maevsi; Owner: postgres
--

CREATE INDEX idx_event_group_author_account_id ON maevsi.event_group USING btree (author_account_id);


--
-- Name: INDEX idx_event_group_author_account_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON INDEX maevsi.idx_event_group_author_account_id IS 'Speeds up reverse foreign key lookups.';


--
-- Name: idx_event_grouping_event_group_id; Type: INDEX; Schema: maevsi; Owner: postgres
--

CREATE INDEX idx_event_grouping_event_group_id ON maevsi.event_grouping USING btree (event_group_id);


--
-- Name: INDEX idx_event_grouping_event_group_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON INDEX maevsi.idx_event_grouping_event_group_id IS 'Speeds up reverse foreign key lookups.';


--
-- Name: idx_event_grouping_event_id; Type: INDEX; Schema: maevsi; Owner: postgres
--

CREATE INDEX idx_event_grouping_event_id ON maevsi.event_grouping USING btree (event_id);


--
-- Name: INDEX idx_event_grouping_event_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON INDEX maevsi.idx_event_grouping_event_id IS 'Speeds up reverse foreign key lookups.';


--
-- Name: idx_event_location; Type: INDEX; Schema: maevsi; Owner: postgres
--

CREATE INDEX idx_event_location ON maevsi.event USING gist (location_geometry);


--
-- Name: INDEX idx_event_location; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON INDEX maevsi.idx_event_location IS 'Spatial index on column location in maevsi.event.';


--
-- Name: idx_invitation_contact_id; Type: INDEX; Schema: maevsi; Owner: postgres
--

CREATE INDEX idx_invitation_contact_id ON maevsi.invitation USING btree (contact_id);


--
-- Name: INDEX idx_invitation_contact_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON INDEX maevsi.idx_invitation_contact_id IS 'Speeds up reverse foreign key lookups.';


--
-- Name: idx_invitation_event_id; Type: INDEX; Schema: maevsi; Owner: postgres
--

CREATE INDEX idx_invitation_event_id ON maevsi.invitation USING btree (event_id);


--
-- Name: INDEX idx_invitation_event_id; Type: COMMENT; Schema: maevsi; Owner: postgres
--

COMMENT ON INDEX maevsi.idx_invitation_event_id IS 'Speeds up reverse foreign key lookups.';


--
-- Name: idx_account_location; Type: INDEX; Schema: maevsi_private; Owner: postgres
--

CREATE INDEX idx_account_location ON maevsi_private.account USING gist (location);


--
-- Name: INDEX idx_account_location; Type: COMMENT; Schema: maevsi_private; Owner: postgres
--

COMMENT ON INDEX maevsi_private.idx_account_location IS 'Spatial index on column location in maevsi_private.account.';


--
-- Name: invitation maevsi_invitation_update; Type: TRIGGER; Schema: maevsi; Owner: postgres
--

CREATE TRIGGER maevsi_invitation_update BEFORE UPDATE ON maevsi.invitation FOR EACH ROW EXECUTE FUNCTION maevsi.trigger_invitation_update();


--
-- Name: legal_term maevsi_legal_term_delete; Type: TRIGGER; Schema: maevsi; Owner: postgres
--

CREATE TRIGGER maevsi_legal_term_delete BEFORE DELETE ON maevsi.legal_term FOR EACH ROW EXECUTE FUNCTION maevsi.legal_term_change();


--
-- Name: legal_term maevsi_legal_term_update; Type: TRIGGER; Schema: maevsi; Owner: postgres
--

CREATE TRIGGER maevsi_legal_term_update BEFORE UPDATE ON maevsi.legal_term FOR EACH ROW EXECUTE FUNCTION maevsi.legal_term_change();


--
-- Name: contact maevsi_trigger_contact_update_account_id; Type: TRIGGER; Schema: maevsi; Owner: postgres
--

CREATE TRIGGER maevsi_trigger_contact_update_account_id BEFORE UPDATE OF account_id, author_account_id ON maevsi.contact FOR EACH ROW EXECUTE FUNCTION maevsi.trigger_contact_update_account_id();


--
-- Name: account maevsi_private_account_email_address_verification_valid_until; Type: TRIGGER; Schema: maevsi_private; Owner: postgres
--

CREATE TRIGGER maevsi_private_account_email_address_verification_valid_until BEFORE INSERT OR UPDATE OF email_address_verification ON maevsi_private.account FOR EACH ROW EXECUTE FUNCTION maevsi_private.account_email_address_verification_valid_until();


--
-- Name: account maevsi_private_account_password_reset_verification_valid_until; Type: TRIGGER; Schema: maevsi_private; Owner: postgres
--

CREATE TRIGGER maevsi_private_account_password_reset_verification_valid_until BEFORE INSERT OR UPDATE OF password_reset_verification ON maevsi_private.account FOR EACH ROW EXECUTE FUNCTION maevsi_private.account_password_reset_verification_valid_until();


--
-- Name: account_block account_block_author_account_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.account_block
    ADD CONSTRAINT account_block_author_account_id_fkey FOREIGN KEY (author_account_id) REFERENCES maevsi.account(id);


--
-- Name: account_block account_block_blocked_account_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.account_block
    ADD CONSTRAINT account_block_blocked_account_id_fkey FOREIGN KEY (blocked_account_id) REFERENCES maevsi.account(id);


--
-- Name: account account_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.account
    ADD CONSTRAINT account_id_fkey FOREIGN KEY (id) REFERENCES maevsi_private.account(id) ON DELETE CASCADE;


--
-- Name: account_interest account_interest_account_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.account_interest
    ADD CONSTRAINT account_interest_account_id_fkey FOREIGN KEY (account_id) REFERENCES maevsi.account(id) ON DELETE CASCADE;


--
-- Name: account_interest account_interest_category_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.account_interest
    ADD CONSTRAINT account_interest_category_fkey FOREIGN KEY (category) REFERENCES maevsi.event_category(category) ON DELETE CASCADE;


--
-- Name: account_preference_event_size account_preference_event_size_account_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.account_preference_event_size
    ADD CONSTRAINT account_preference_event_size_account_id_fkey FOREIGN KEY (account_id) REFERENCES maevsi.account(id);


--
-- Name: account_social_network account_social_network_account_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.account_social_network
    ADD CONSTRAINT account_social_network_account_id_fkey FOREIGN KEY (account_id) REFERENCES maevsi.account(id) ON DELETE CASCADE;


--
-- Name: achievement achievement_account_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.achievement
    ADD CONSTRAINT achievement_account_id_fkey FOREIGN KEY (account_id) REFERENCES maevsi.account(id);


--
-- Name: contact contact_account_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.contact
    ADD CONSTRAINT contact_account_id_fkey FOREIGN KEY (account_id) REFERENCES maevsi.account(id);


--
-- Name: contact contact_author_account_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.contact
    ADD CONSTRAINT contact_author_account_id_fkey FOREIGN KEY (author_account_id) REFERENCES maevsi.account(id) ON DELETE CASCADE;


--
-- Name: event event_author_account_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event
    ADD CONSTRAINT event_author_account_id_fkey FOREIGN KEY (author_account_id) REFERENCES maevsi.account(id);


--
-- Name: event_category_mapping event_category_mapping_category_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_category_mapping
    ADD CONSTRAINT event_category_mapping_category_fkey FOREIGN KEY (category) REFERENCES maevsi.event_category(category) ON DELETE CASCADE;


--
-- Name: event_category_mapping event_category_mapping_event_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_category_mapping
    ADD CONSTRAINT event_category_mapping_event_id_fkey FOREIGN KEY (event_id) REFERENCES maevsi.event(id) ON DELETE CASCADE;


--
-- Name: event_favourite event_favourite_account_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_favourite
    ADD CONSTRAINT event_favourite_account_id_fkey FOREIGN KEY (account_id) REFERENCES maevsi.account(id) ON DELETE CASCADE;


--
-- Name: event_favourite event_favourite_event_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_favourite
    ADD CONSTRAINT event_favourite_event_id_fkey FOREIGN KEY (event_id) REFERENCES maevsi.event(id) ON DELETE CASCADE;


--
-- Name: event_group event_group_author_account_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_group
    ADD CONSTRAINT event_group_author_account_id_fkey FOREIGN KEY (author_account_id) REFERENCES maevsi.account(id);


--
-- Name: event_grouping event_grouping_event_group_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_grouping
    ADD CONSTRAINT event_grouping_event_group_id_fkey FOREIGN KEY (event_group_id) REFERENCES maevsi.event_group(id);


--
-- Name: event_grouping event_grouping_event_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_grouping
    ADD CONSTRAINT event_grouping_event_id_fkey FOREIGN KEY (event_id) REFERENCES maevsi.event(id);


--
-- Name: event_recommendation event_recommendation_account_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_recommendation
    ADD CONSTRAINT event_recommendation_account_id_fkey FOREIGN KEY (account_id) REFERENCES maevsi.account(id) ON DELETE CASCADE;


--
-- Name: event_recommendation event_recommendation_event_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_recommendation
    ADD CONSTRAINT event_recommendation_event_id_fkey FOREIGN KEY (event_id) REFERENCES maevsi.event(id) ON DELETE CASCADE;


--
-- Name: event_upload event_upload_event_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_upload
    ADD CONSTRAINT event_upload_event_id_fkey FOREIGN KEY (event_id) REFERENCES maevsi.event(id);


--
-- Name: event_upload event_upload_upload_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.event_upload
    ADD CONSTRAINT event_upload_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES maevsi.upload(id);


--
-- Name: invitation invitation_contact_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.invitation
    ADD CONSTRAINT invitation_contact_id_fkey FOREIGN KEY (contact_id) REFERENCES maevsi.contact(id);


--
-- Name: invitation invitation_event_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.invitation
    ADD CONSTRAINT invitation_event_id_fkey FOREIGN KEY (event_id) REFERENCES maevsi.event(id);


--
-- Name: invitation invitation_updated_by_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.invitation
    ADD CONSTRAINT invitation_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES maevsi.account(id);


--
-- Name: legal_term_acceptance legal_term_acceptance_account_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.legal_term_acceptance
    ADD CONSTRAINT legal_term_acceptance_account_id_fkey FOREIGN KEY (account_id) REFERENCES maevsi.account(id) ON DELETE CASCADE;


--
-- Name: legal_term_acceptance legal_term_acceptance_legal_term_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.legal_term_acceptance
    ADD CONSTRAINT legal_term_acceptance_legal_term_id_fkey FOREIGN KEY (legal_term_id) REFERENCES maevsi.legal_term(id) ON DELETE RESTRICT;


--
-- Name: profile_picture profile_picture_account_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.profile_picture
    ADD CONSTRAINT profile_picture_account_id_fkey FOREIGN KEY (account_id) REFERENCES maevsi.account(id);


--
-- Name: profile_picture profile_picture_upload_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.profile_picture
    ADD CONSTRAINT profile_picture_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES maevsi.upload(id);


--
-- Name: report report_author_account_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.report
    ADD CONSTRAINT report_author_account_id_fkey FOREIGN KEY (author_account_id) REFERENCES maevsi.account(id);


--
-- Name: report report_target_account_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.report
    ADD CONSTRAINT report_target_account_id_fkey FOREIGN KEY (target_account_id) REFERENCES maevsi.account(id);


--
-- Name: report report_target_event_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.report
    ADD CONSTRAINT report_target_event_id_fkey FOREIGN KEY (target_event_id) REFERENCES maevsi.event(id);


--
-- Name: report report_target_upload_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.report
    ADD CONSTRAINT report_target_upload_id_fkey FOREIGN KEY (target_upload_id) REFERENCES maevsi.upload(id);


--
-- Name: upload upload_account_id_fkey; Type: FK CONSTRAINT; Schema: maevsi; Owner: postgres
--

ALTER TABLE ONLY maevsi.upload
    ADD CONSTRAINT upload_account_id_fkey FOREIGN KEY (account_id) REFERENCES maevsi.account(id);


--
-- Name: changes changes_project_fkey; Type: FK CONSTRAINT; Schema: sqitch; Owner: postgres
--

ALTER TABLE ONLY sqitch.changes
    ADD CONSTRAINT changes_project_fkey FOREIGN KEY (project) REFERENCES sqitch.projects(project) ON UPDATE CASCADE;


--
-- Name: dependencies dependencies_change_id_fkey; Type: FK CONSTRAINT; Schema: sqitch; Owner: postgres
--

ALTER TABLE ONLY sqitch.dependencies
    ADD CONSTRAINT dependencies_change_id_fkey FOREIGN KEY (change_id) REFERENCES sqitch.changes(change_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: dependencies dependencies_dependency_id_fkey; Type: FK CONSTRAINT; Schema: sqitch; Owner: postgres
--

ALTER TABLE ONLY sqitch.dependencies
    ADD CONSTRAINT dependencies_dependency_id_fkey FOREIGN KEY (dependency_id) REFERENCES sqitch.changes(change_id) ON UPDATE CASCADE;


--
-- Name: events events_project_fkey; Type: FK CONSTRAINT; Schema: sqitch; Owner: postgres
--

ALTER TABLE ONLY sqitch.events
    ADD CONSTRAINT events_project_fkey FOREIGN KEY (project) REFERENCES sqitch.projects(project) ON UPDATE CASCADE;


--
-- Name: tags tags_change_id_fkey; Type: FK CONSTRAINT; Schema: sqitch; Owner: postgres
--

ALTER TABLE ONLY sqitch.tags
    ADD CONSTRAINT tags_change_id_fkey FOREIGN KEY (change_id) REFERENCES sqitch.changes(change_id) ON UPDATE CASCADE;


--
-- Name: tags tags_project_fkey; Type: FK CONSTRAINT; Schema: sqitch; Owner: postgres
--

ALTER TABLE ONLY sqitch.tags
    ADD CONSTRAINT tags_project_fkey FOREIGN KEY (project) REFERENCES sqitch.projects(project) ON UPDATE CASCADE;


--
-- Name: account; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.account ENABLE ROW LEVEL SECURITY;

--
-- Name: account_block; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.account_block ENABLE ROW LEVEL SECURITY;

--
-- Name: account_block account_block_insert; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY account_block_insert ON maevsi.account_block FOR INSERT WITH CHECK (((maevsi.invoker_account_id() IS NOT NULL) AND (author_account_id = maevsi.invoker_account_id())));


--
-- Name: account_block account_block_select; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY account_block_select ON maevsi.account_block FOR SELECT USING (((author_account_id = maevsi.invoker_account_id()) OR (blocked_account_id = maevsi.invoker_account_id())));


--
-- Name: account_interest; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.account_interest ENABLE ROW LEVEL SECURITY;

--
-- Name: account_interest account_interest_delete; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY account_interest_delete ON maevsi.account_interest FOR DELETE USING ((account_id = maevsi.invoker_account_id()));


--
-- Name: account_interest account_interest_insert; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY account_interest_insert ON maevsi.account_interest FOR INSERT WITH CHECK ((account_id = maevsi.invoker_account_id()));


--
-- Name: account_interest account_interest_select; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY account_interest_select ON maevsi.account_interest FOR SELECT USING ((account_id = maevsi.invoker_account_id()));


--
-- Name: account_preference_event_size; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.account_preference_event_size ENABLE ROW LEVEL SECURITY;

--
-- Name: account_preference_event_size account_preference_event_size_delete; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY account_preference_event_size_delete ON maevsi.account_preference_event_size FOR DELETE USING ((account_id = maevsi.invoker_account_id()));


--
-- Name: account_preference_event_size account_preference_event_size_insert; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY account_preference_event_size_insert ON maevsi.account_preference_event_size FOR INSERT WITH CHECK ((account_id = maevsi.invoker_account_id()));


--
-- Name: account_preference_event_size account_preference_event_size_select; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY account_preference_event_size_select ON maevsi.account_preference_event_size FOR SELECT USING ((account_id = maevsi.invoker_account_id()));


--
-- Name: account account_select; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY account_select ON maevsi.account FOR SELECT USING (true);


--
-- Name: account_social_network; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.account_social_network ENABLE ROW LEVEL SECURITY;

--
-- Name: account_social_network account_social_network_delete; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY account_social_network_delete ON maevsi.account_social_network FOR DELETE USING ((account_id = maevsi.invoker_account_id()));


--
-- Name: account_social_network account_social_network_insert; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY account_social_network_insert ON maevsi.account_social_network FOR INSERT WITH CHECK ((account_id = maevsi.invoker_account_id()));


--
-- Name: account_social_network account_social_network_update; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY account_social_network_update ON maevsi.account_social_network FOR UPDATE USING ((account_id = maevsi.invoker_account_id()));


--
-- Name: achievement; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.achievement ENABLE ROW LEVEL SECURITY;

--
-- Name: achievement achievement_select; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY achievement_select ON maevsi.achievement FOR SELECT USING (true);


--
-- Name: contact; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.contact ENABLE ROW LEVEL SECURITY;

--
-- Name: contact contact_delete; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY contact_delete ON maevsi.contact FOR DELETE USING (((maevsi.invoker_account_id() IS NOT NULL) AND (author_account_id = maevsi.invoker_account_id()) AND (account_id IS DISTINCT FROM maevsi.invoker_account_id())));


--
-- Name: contact contact_insert; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY contact_insert ON maevsi.contact FOR INSERT WITH CHECK (((author_account_id = maevsi.invoker_account_id()) AND (NOT (account_id IN ( SELECT account_block.blocked_account_id
   FROM maevsi.account_block
  WHERE (account_block.author_account_id = maevsi.invoker_account_id()))))));


--
-- Name: contact contact_select; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY contact_select ON maevsi.contact FOR SELECT USING ((((account_id = maevsi.invoker_account_id()) AND (NOT (author_account_id IN ( SELECT account_block.blocked_account_id
   FROM maevsi.account_block
  WHERE (account_block.author_account_id = maevsi.invoker_account_id())
UNION ALL
 SELECT account_block.author_account_id
   FROM maevsi.account_block
  WHERE (account_block.blocked_account_id = maevsi.invoker_account_id()))))) OR ((author_account_id = maevsi.invoker_account_id()) AND ((account_id IS NULL) OR (NOT (account_id IN ( SELECT account_block.blocked_account_id
   FROM maevsi.account_block
  WHERE (account_block.author_account_id = maevsi.invoker_account_id())
UNION ALL
 SELECT account_block.author_account_id
   FROM maevsi.account_block
  WHERE (account_block.blocked_account_id = maevsi.invoker_account_id())))))) OR (id IN ( SELECT maevsi.invitation_contact_ids() AS invitation_contact_ids))));


--
-- Name: contact contact_update; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY contact_update ON maevsi.contact FOR UPDATE USING (((author_account_id = maevsi.invoker_account_id()) AND (NOT (account_id IN ( SELECT account_block.blocked_account_id
   FROM maevsi.account_block
  WHERE (account_block.author_account_id = maevsi.invoker_account_id()))))));


--
-- Name: event; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.event ENABLE ROW LEVEL SECURITY;

--
-- Name: event_category_mapping; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.event_category_mapping ENABLE ROW LEVEL SECURITY;

--
-- Name: event_category_mapping event_category_mapping_delete; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY event_category_mapping_delete ON maevsi.event_category_mapping FOR DELETE USING (((maevsi.invoker_account_id() IS NOT NULL) AND (( SELECT event.author_account_id
   FROM maevsi.event
  WHERE (event.id = event_category_mapping.event_id)) = maevsi.invoker_account_id())));


--
-- Name: event_category_mapping event_category_mapping_insert; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY event_category_mapping_insert ON maevsi.event_category_mapping FOR INSERT WITH CHECK (((maevsi.invoker_account_id() IS NOT NULL) AND (( SELECT event.author_account_id
   FROM maevsi.event
  WHERE (event.id = event_category_mapping.event_id)) = maevsi.invoker_account_id())));


--
-- Name: event_category_mapping event_category_mapping_select; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY event_category_mapping_select ON maevsi.event_category_mapping FOR SELECT USING ((((maevsi.invoker_account_id() IS NOT NULL) AND (( SELECT event.author_account_id
   FROM maevsi.event
  WHERE (event.id = event_category_mapping.event_id)) = maevsi.invoker_account_id())) OR (event_id IN ( SELECT maevsi_private.events_invited() AS events_invited)) OR ((( SELECT event.visibility
   FROM maevsi.event
  WHERE (event.id = event_category_mapping.event_id)) = 'public'::maevsi.event_visibility) AND (NOT (( SELECT event.author_account_id
   FROM maevsi.event
  WHERE (event.id = event_category_mapping.event_id)) IN ( SELECT account_block.blocked_account_id
   FROM maevsi.account_block
  WHERE (account_block.author_account_id = maevsi.invoker_account_id())
UNION ALL
 SELECT account_block.author_account_id
   FROM maevsi.account_block
  WHERE (account_block.blocked_account_id = maevsi.invoker_account_id())))))));


--
-- Name: event_favourite; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.event_favourite ENABLE ROW LEVEL SECURITY;

--
-- Name: event_favourite event_favourite_select; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY event_favourite_select ON maevsi.event_favourite FOR SELECT USING (((maevsi.invoker_account_id() IS NOT NULL) AND (account_id = maevsi.invoker_account_id())));


--
-- Name: event_group; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.event_group ENABLE ROW LEVEL SECURITY;

--
-- Name: event_grouping; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.event_grouping ENABLE ROW LEVEL SECURITY;

--
-- Name: event event_insert; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY event_insert ON maevsi.event FOR INSERT WITH CHECK (((maevsi.invoker_account_id() IS NOT NULL) AND (author_account_id = maevsi.invoker_account_id())));


--
-- Name: event_recommendation; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.event_recommendation ENABLE ROW LEVEL SECURITY;

--
-- Name: event_recommendation event_recommendation_select; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY event_recommendation_select ON maevsi.event_recommendation FOR SELECT USING (((maevsi.invoker_account_id() IS NOT NULL) AND (account_id = maevsi.invoker_account_id())));


--
-- Name: event event_select; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY event_select ON maevsi.event FOR SELECT USING ((((visibility = 'public'::maevsi.event_visibility) AND ((invitee_count_maximum IS NULL) OR (invitee_count_maximum > maevsi.invitee_count(id))) AND (NOT (author_account_id IN ( SELECT account_block.blocked_account_id
   FROM maevsi.account_block
  WHERE (account_block.author_account_id = maevsi.invoker_account_id())
UNION ALL
 SELECT account_block.author_account_id
   FROM maevsi.account_block
  WHERE (account_block.blocked_account_id = maevsi.invoker_account_id()))))) OR (author_account_id = maevsi.invoker_account_id()) OR (id IN ( SELECT maevsi_private.events_invited() AS events_invited))));


--
-- Name: event event_update; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY event_update ON maevsi.event FOR UPDATE USING (((maevsi.invoker_account_id() IS NOT NULL) AND (author_account_id = maevsi.invoker_account_id())));


--
-- Name: event_upload; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.event_upload ENABLE ROW LEVEL SECURITY;

--
-- Name: event_upload event_upload_delete; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY event_upload_delete ON maevsi.event_upload FOR DELETE USING ((event_id IN ( SELECT event.id
   FROM maevsi.event
  WHERE (event.author_account_id = maevsi.invoker_account_id()))));


--
-- Name: event_upload event_upload_insert; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY event_upload_insert ON maevsi.event_upload FOR INSERT WITH CHECK (((event_id IN ( SELECT event.id
   FROM maevsi.event
  WHERE (event.author_account_id = maevsi.invoker_account_id()))) AND (upload_id IN ( SELECT upload.id
   FROM maevsi.upload
  WHERE (upload.account_id = maevsi.invoker_account_id())))));


--
-- Name: event_upload event_upload_select; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY event_upload_select ON maevsi.event_upload FOR SELECT USING ((event_id IN ( SELECT event.id
   FROM maevsi.event)));


--
-- Name: invitation; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.invitation ENABLE ROW LEVEL SECURITY;

--
-- Name: invitation invitation_delete; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY invitation_delete ON maevsi.invitation FOR DELETE USING ((event_id IN ( SELECT maevsi.events_organized() AS events_organized)));


--
-- Name: invitation invitation_insert; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY invitation_insert ON maevsi.invitation FOR INSERT WITH CHECK (((event_id IN ( SELECT maevsi.events_organized() AS events_organized)) AND ((maevsi.event_invitee_count_maximum(event_id) IS NULL) OR (maevsi.event_invitee_count_maximum(event_id) > maevsi.invitee_count(event_id))) AND (contact_id IN ( SELECT contact.id
   FROM maevsi.contact
  WHERE (contact.author_account_id = maevsi.invoker_account_id())
EXCEPT
 SELECT c.id
   FROM (maevsi.contact c
     JOIN maevsi.account_block b ON (((c.account_id = b.blocked_account_id) AND (c.author_account_id = b.author_account_id))))
  WHERE (c.author_account_id = maevsi.invoker_account_id())))));


--
-- Name: invitation invitation_select; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY invitation_select ON maevsi.invitation FOR SELECT USING (((id = ANY (maevsi.invitation_claim_array())) OR (contact_id IN ( SELECT contact.id
   FROM maevsi.contact
  WHERE (contact.account_id = maevsi.invoker_account_id())
EXCEPT
 SELECT c.id
   FROM (maevsi.contact c
     JOIN maevsi.account_block b ON (((c.account_id = b.author_account_id) AND (c.author_account_id = b.blocked_account_id))))
  WHERE (c.account_id = maevsi.invoker_account_id()))) OR ((event_id IN ( SELECT maevsi.events_organized() AS events_organized)) AND (contact_id IN ( SELECT c.id
   FROM maevsi.contact c
  WHERE ((c.account_id IS NULL) OR (NOT (c.account_id IN ( SELECT account_block.blocked_account_id
           FROM maevsi.account_block
          WHERE (account_block.author_account_id = maevsi.invoker_account_id())
        UNION ALL
         SELECT account_block.author_account_id
           FROM maevsi.account_block
          WHERE (account_block.blocked_account_id = maevsi.invoker_account_id()))))))))));


--
-- Name: invitation invitation_update; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY invitation_update ON maevsi.invitation FOR UPDATE USING (((id = ANY (maevsi.invitation_claim_array())) OR (contact_id IN ( SELECT contact.id
   FROM maevsi.contact
  WHERE (contact.account_id = maevsi.invoker_account_id())
EXCEPT
 SELECT c.id
   FROM (maevsi.contact c
     JOIN maevsi.account_block b ON (((c.account_id = b.author_account_id) AND (c.author_account_id = b.blocked_account_id))))
  WHERE (c.account_id = maevsi.invoker_account_id()))) OR ((event_id IN ( SELECT maevsi.events_organized() AS events_organized)) AND (contact_id IN ( SELECT c.id
   FROM maevsi.contact c
  WHERE ((c.account_id IS NULL) OR (NOT (c.account_id IN ( SELECT account_block.blocked_account_id
           FROM maevsi.account_block
          WHERE (account_block.author_account_id = maevsi.invoker_account_id())
        UNION ALL
         SELECT account_block.author_account_id
           FROM maevsi.account_block
          WHERE (account_block.blocked_account_id = maevsi.invoker_account_id()))))))))));


--
-- Name: legal_term; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.legal_term ENABLE ROW LEVEL SECURITY;

--
-- Name: legal_term_acceptance; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.legal_term_acceptance ENABLE ROW LEVEL SECURITY;

--
-- Name: legal_term_acceptance legal_term_acceptance_insert; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY legal_term_acceptance_insert ON maevsi.legal_term_acceptance FOR INSERT WITH CHECK (((maevsi.invoker_account_id() IS NOT NULL) AND (account_id = maevsi.invoker_account_id())));


--
-- Name: legal_term_acceptance legal_term_acceptance_select; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY legal_term_acceptance_select ON maevsi.legal_term_acceptance FOR SELECT USING (((maevsi.invoker_account_id() IS NOT NULL) AND (account_id = maevsi.invoker_account_id())));


--
-- Name: legal_term legal_term_select; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY legal_term_select ON maevsi.legal_term FOR SELECT USING (true);


--
-- Name: profile_picture; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.profile_picture ENABLE ROW LEVEL SECURITY;

--
-- Name: profile_picture profile_picture_delete; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY profile_picture_delete ON maevsi.profile_picture FOR DELETE USING (((( SELECT CURRENT_USER AS "current_user") = 'maevsi_tusd'::name) OR ((maevsi.invoker_account_id() IS NOT NULL) AND (account_id = maevsi.invoker_account_id()))));


--
-- Name: profile_picture profile_picture_insert; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY profile_picture_insert ON maevsi.profile_picture FOR INSERT WITH CHECK (((maevsi.invoker_account_id() IS NOT NULL) AND (account_id = maevsi.invoker_account_id())));


--
-- Name: profile_picture profile_picture_select; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY profile_picture_select ON maevsi.profile_picture FOR SELECT USING (true);


--
-- Name: profile_picture profile_picture_update; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY profile_picture_update ON maevsi.profile_picture FOR UPDATE USING (((maevsi.invoker_account_id() IS NOT NULL) AND (account_id = maevsi.invoker_account_id())));


--
-- Name: report; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.report ENABLE ROW LEVEL SECURITY;

--
-- Name: report report_insert; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY report_insert ON maevsi.report FOR INSERT WITH CHECK (((maevsi.invoker_account_id() IS NOT NULL) AND (author_account_id = maevsi.invoker_account_id())));


--
-- Name: report report_select; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY report_select ON maevsi.report FOR SELECT USING (((maevsi.invoker_account_id() IS NOT NULL) AND (author_account_id = maevsi.invoker_account_id())));


--
-- Name: upload; Type: ROW SECURITY; Schema: maevsi; Owner: postgres
--

ALTER TABLE maevsi.upload ENABLE ROW LEVEL SECURITY;

--
-- Name: upload upload_delete_using; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY upload_delete_using ON maevsi.upload FOR DELETE USING ((( SELECT CURRENT_USER AS "current_user") = 'maevsi_tusd'::name));


--
-- Name: upload upload_select_using; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY upload_select_using ON maevsi.upload FOR SELECT USING (((( SELECT CURRENT_USER AS "current_user") = 'maevsi_tusd'::name) OR ((maevsi.invoker_account_id() IS NOT NULL) AND (account_id = maevsi.invoker_account_id())) OR (id IN ( SELECT profile_picture.upload_id
   FROM maevsi.profile_picture))));


--
-- Name: upload upload_update_using; Type: POLICY; Schema: maevsi; Owner: postgres
--

CREATE POLICY upload_update_using ON maevsi.upload FOR UPDATE USING ((( SELECT CURRENT_USER AS "current_user") = 'maevsi_tusd'::name));


--
-- Name: achievement_code; Type: ROW SECURITY; Schema: maevsi_private; Owner: postgres
--

ALTER TABLE maevsi_private.achievement_code ENABLE ROW LEVEL SECURITY;

--
-- Name: achievement_code achievement_code_select; Type: POLICY; Schema: maevsi_private; Owner: postgres
--

CREATE POLICY achievement_code_select ON maevsi_private.achievement_code FOR SELECT USING (true);


--
-- Name: SCHEMA maevsi; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA maevsi TO maevsi_anonymous;
GRANT USAGE ON SCHEMA maevsi TO maevsi_account;
GRANT USAGE ON SCHEMA maevsi TO maevsi_tusd;


--
-- Name: FUNCTION box2d_in(cstring); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.box2d_in(cstring) FROM PUBLIC;


--
-- Name: FUNCTION box2d_out(maevsi.box2d); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.box2d_out(maevsi.box2d) FROM PUBLIC;


--
-- Name: FUNCTION box2df_in(cstring); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.box2df_in(cstring) FROM PUBLIC;


--
-- Name: FUNCTION box2df_out(maevsi.box2df); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.box2df_out(maevsi.box2df) FROM PUBLIC;


--
-- Name: FUNCTION box3d_in(cstring); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.box3d_in(cstring) FROM PUBLIC;


--
-- Name: FUNCTION box3d_out(maevsi.box3d); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.box3d_out(maevsi.box3d) FROM PUBLIC;


--
-- Name: FUNCTION geography_analyze(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_analyze(internal) FROM PUBLIC;


--
-- Name: FUNCTION geography_in(cstring, oid, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_in(cstring, oid, integer) FROM PUBLIC;


--
-- Name: FUNCTION geography_out(maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_out(maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION geography_recv(internal, oid, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_recv(internal, oid, integer) FROM PUBLIC;


--
-- Name: FUNCTION geography_send(maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_send(maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION geography_typmod_in(cstring[]); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_typmod_in(cstring[]) FROM PUBLIC;


--
-- Name: FUNCTION geography_typmod_out(integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_typmod_out(integer) FROM PUBLIC;


--
-- Name: FUNCTION geometry_analyze(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_analyze(internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_in(cstring); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_in(cstring) FROM PUBLIC;


--
-- Name: FUNCTION geometry_out(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_out(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_recv(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_recv(internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_send(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_send(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_typmod_in(cstring[]); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_typmod_in(cstring[]) FROM PUBLIC;


--
-- Name: FUNCTION geometry_typmod_out(integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_typmod_out(integer) FROM PUBLIC;


--
-- Name: FUNCTION gidx_in(cstring); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.gidx_in(cstring) FROM PUBLIC;


--
-- Name: FUNCTION gidx_out(maevsi.gidx); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.gidx_out(maevsi.gidx) FROM PUBLIC;


--
-- Name: FUNCTION spheroid_in(cstring); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.spheroid_in(cstring) FROM PUBLIC;


--
-- Name: FUNCTION spheroid_out(maevsi.spheroid); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.spheroid_out(maevsi.spheroid) FROM PUBLIC;


--
-- Name: FUNCTION box3d(maevsi.box2d); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.box3d(maevsi.box2d) FROM PUBLIC;


--
-- Name: FUNCTION geometry(maevsi.box2d); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry(maevsi.box2d) FROM PUBLIC;


--
-- Name: FUNCTION box(maevsi.box3d); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.box(maevsi.box3d) FROM PUBLIC;


--
-- Name: FUNCTION box2d(maevsi.box3d); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.box2d(maevsi.box3d) FROM PUBLIC;


--
-- Name: FUNCTION geometry(maevsi.box3d); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry(maevsi.box3d) FROM PUBLIC;


--
-- Name: FUNCTION geography(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography(bytea) FROM PUBLIC;


--
-- Name: FUNCTION geometry(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry(bytea) FROM PUBLIC;


--
-- Name: FUNCTION bytea(maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.bytea(maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION geography(maevsi.geography, integer, boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography(maevsi.geography, integer, boolean) FROM PUBLIC;


--
-- Name: FUNCTION geometry(maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry(maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION box(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.box(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION box2d(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.box2d(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION box3d(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.box3d(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION bytea(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.bytea(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geography(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry(maevsi.geometry, integer, boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry(maevsi.geometry, integer, boolean) FROM PUBLIC;


--
-- Name: FUNCTION "json"(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi."json"(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION jsonb(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.jsonb(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION path(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.path(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION point(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.point(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION polygon(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.polygon(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION text(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.text(maevsi.geometry) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.text(maevsi.geometry) TO maevsi_anonymous;
GRANT ALL ON FUNCTION maevsi.text(maevsi.geometry) TO maevsi_account;


--
-- Name: FUNCTION geometry(path); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry(path) FROM PUBLIC;


--
-- Name: FUNCTION geometry(point); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry(point) FROM PUBLIC;


--
-- Name: FUNCTION geometry(polygon); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry(polygon) FROM PUBLIC;


--
-- Name: FUNCTION geometry(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry(text) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.geometry(text) TO maevsi_anonymous;
GRANT ALL ON FUNCTION maevsi.geometry(text) TO maevsi_account;


--
-- Name: FUNCTION _postgis_deprecate(oldname text, newname text, version text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._postgis_deprecate(oldname text, newname text, version text) FROM PUBLIC;


--
-- Name: FUNCTION _postgis_index_extent(tbl regclass, col text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._postgis_index_extent(tbl regclass, col text) FROM PUBLIC;


--
-- Name: FUNCTION _postgis_join_selectivity(regclass, text, regclass, text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._postgis_join_selectivity(regclass, text, regclass, text, text) FROM PUBLIC;


--
-- Name: FUNCTION _postgis_pgsql_version(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._postgis_pgsql_version() FROM PUBLIC;


--
-- Name: FUNCTION _postgis_scripts_pgsql_version(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._postgis_scripts_pgsql_version() FROM PUBLIC;


--
-- Name: FUNCTION _postgis_selectivity(tbl regclass, att_name text, geom maevsi.geometry, mode text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._postgis_selectivity(tbl regclass, att_name text, geom maevsi.geometry, mode text) FROM PUBLIC;


--
-- Name: FUNCTION _postgis_stats(tbl regclass, att_name text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._postgis_stats(tbl regclass, att_name text, text) FROM PUBLIC;


--
-- Name: FUNCTION _st_3ddfullywithin(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_3ddfullywithin(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION _st_3ddwithin(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_3ddwithin(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION _st_3dintersects(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_3dintersects(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION _st_asgml(integer, maevsi.geometry, integer, integer, text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_asgml(integer, maevsi.geometry, integer, integer, text, text) FROM PUBLIC;


--
-- Name: FUNCTION _st_asx3d(integer, maevsi.geometry, integer, integer, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_asx3d(integer, maevsi.geometry, integer, integer, text) FROM PUBLIC;


--
-- Name: FUNCTION _st_bestsrid(maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_bestsrid(maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION _st_bestsrid(maevsi.geography, maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_bestsrid(maevsi.geography, maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION _st_concavehull(param_inputgeom maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_concavehull(param_inputgeom maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION _st_contains(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_contains(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION _st_containsproperly(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_containsproperly(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION _st_coveredby(geog1 maevsi.geography, geog2 maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_coveredby(geog1 maevsi.geography, geog2 maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION _st_coveredby(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_coveredby(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION _st_covers(geog1 maevsi.geography, geog2 maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_covers(geog1 maevsi.geography, geog2 maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION _st_covers(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_covers(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION _st_crosses(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_crosses(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION _st_dfullywithin(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_dfullywithin(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION _st_distancetree(maevsi.geography, maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_distancetree(maevsi.geography, maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION _st_distancetree(maevsi.geography, maevsi.geography, double precision, boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_distancetree(maevsi.geography, maevsi.geography, double precision, boolean) FROM PUBLIC;


--
-- Name: FUNCTION _st_distanceuncached(maevsi.geography, maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_distanceuncached(maevsi.geography, maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION _st_distanceuncached(maevsi.geography, maevsi.geography, boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_distanceuncached(maevsi.geography, maevsi.geography, boolean) FROM PUBLIC;


--
-- Name: FUNCTION _st_distanceuncached(maevsi.geography, maevsi.geography, double precision, boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_distanceuncached(maevsi.geography, maevsi.geography, double precision, boolean) FROM PUBLIC;


--
-- Name: FUNCTION _st_dwithin(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_dwithin(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION _st_dwithin(geog1 maevsi.geography, geog2 maevsi.geography, tolerance double precision, use_spheroid boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_dwithin(geog1 maevsi.geography, geog2 maevsi.geography, tolerance double precision, use_spheroid boolean) FROM PUBLIC;


--
-- Name: FUNCTION _st_dwithinuncached(maevsi.geography, maevsi.geography, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_dwithinuncached(maevsi.geography, maevsi.geography, double precision) FROM PUBLIC;


--
-- Name: FUNCTION _st_dwithinuncached(maevsi.geography, maevsi.geography, double precision, boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_dwithinuncached(maevsi.geography, maevsi.geography, double precision, boolean) FROM PUBLIC;


--
-- Name: FUNCTION _st_equals(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_equals(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION _st_expand(maevsi.geography, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_expand(maevsi.geography, double precision) FROM PUBLIC;


--
-- Name: FUNCTION _st_geomfromgml(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_geomfromgml(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION _st_intersects(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_intersects(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION _st_linecrossingdirection(line1 maevsi.geometry, line2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_linecrossingdirection(line1 maevsi.geometry, line2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION _st_longestline(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_longestline(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION _st_maxdistance(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_maxdistance(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION _st_orderingequals(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_orderingequals(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION _st_overlaps(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_overlaps(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION _st_pointoutside(maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_pointoutside(maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION _st_sortablehash(geom maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_sortablehash(geom maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION _st_touches(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_touches(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION _st_voronoi(g1 maevsi.geometry, clip maevsi.geometry, tolerance double precision, return_polygons boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_voronoi(g1 maevsi.geometry, clip maevsi.geometry, tolerance double precision, return_polygons boolean) FROM PUBLIC;


--
-- Name: FUNCTION _st_within(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi._st_within(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION account_delete(password text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.account_delete(password text) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.account_delete(password text) TO maevsi_account;


--
-- Name: FUNCTION account_distances(_event_id uuid, _max_distance double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.account_distances(_event_id uuid, _max_distance double precision) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.account_distances(_event_id uuid, _max_distance double precision) TO maevsi_account;


--
-- Name: FUNCTION account_email_address_verification(code uuid); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.account_email_address_verification(code uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.account_email_address_verification(code uuid) TO maevsi_account;
GRANT ALL ON FUNCTION maevsi.account_email_address_verification(code uuid) TO maevsi_anonymous;


--
-- Name: FUNCTION account_location_update(_account_id uuid, _latitude double precision, _longitude double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.account_location_update(_account_id uuid, _latitude double precision, _longitude double precision) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.account_location_update(_account_id uuid, _latitude double precision, _longitude double precision) TO maevsi_account;


--
-- Name: FUNCTION account_password_change(password_current text, password_new text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.account_password_change(password_current text, password_new text) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.account_password_change(password_current text, password_new text) TO maevsi_account;


--
-- Name: FUNCTION account_password_reset(code uuid, password text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.account_password_reset(code uuid, password text) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.account_password_reset(code uuid, password text) TO maevsi_anonymous;
GRANT ALL ON FUNCTION maevsi.account_password_reset(code uuid, password text) TO maevsi_account;


--
-- Name: FUNCTION account_password_reset_request(email_address text, language text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.account_password_reset_request(email_address text, language text) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.account_password_reset_request(email_address text, language text) TO maevsi_anonymous;
GRANT ALL ON FUNCTION maevsi.account_password_reset_request(email_address text, language text) TO maevsi_account;


--
-- Name: FUNCTION account_registration(username text, email_address text, password text, language text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.account_registration(username text, email_address text, password text, language text) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.account_registration(username text, email_address text, password text, language text) TO maevsi_anonymous;
GRANT ALL ON FUNCTION maevsi.account_registration(username text, email_address text, password text, language text) TO maevsi_account;


--
-- Name: FUNCTION account_registration_refresh(account_id uuid, language text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.account_registration_refresh(account_id uuid, language text) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.account_registration_refresh(account_id uuid, language text) TO maevsi_anonymous;


--
-- Name: FUNCTION account_upload_quota_bytes(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.account_upload_quota_bytes() FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.account_upload_quota_bytes() TO maevsi_account;


--
-- Name: FUNCTION achievement_unlock(code uuid, alias text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.achievement_unlock(code uuid, alias text) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.achievement_unlock(code uuid, alias text) TO maevsi_account;


--
-- Name: FUNCTION addgeometrycolumn(table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.addgeometrycolumn(table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean) FROM PUBLIC;


--
-- Name: FUNCTION addgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.addgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean) FROM PUBLIC;


--
-- Name: FUNCTION addgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer, new_type character varying, new_dim integer, use_typmod boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.addgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer, new_type character varying, new_dim integer, use_typmod boolean) FROM PUBLIC;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.armor(bytea) FROM PUBLIC;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.armor(bytea, text[], text[]) FROM PUBLIC;


--
-- Name: FUNCTION authenticate(username text, password text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.authenticate(username text, password text) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.authenticate(username text, password text) TO maevsi_account;
GRANT ALL ON FUNCTION maevsi.authenticate(username text, password text) TO maevsi_anonymous;


--
-- Name: FUNCTION box3dtobox(maevsi.box3d); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.box3dtobox(maevsi.box3d) FROM PUBLIC;


--
-- Name: FUNCTION contains_2d(maevsi.box2df, maevsi.box2df); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.contains_2d(maevsi.box2df, maevsi.box2df) FROM PUBLIC;


--
-- Name: FUNCTION contains_2d(maevsi.box2df, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.contains_2d(maevsi.box2df, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION contains_2d(maevsi.geometry, maevsi.box2df); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.contains_2d(maevsi.geometry, maevsi.box2df) FROM PUBLIC;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.crypt(text, text) FROM PUBLIC;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.dearmor(text) FROM PUBLIC;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.decrypt(bytea, bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.decrypt_iv(bytea, bytea, bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.digest(bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.digest(text, text) FROM PUBLIC;


--
-- Name: FUNCTION dropgeometrycolumn(table_name character varying, column_name character varying); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.dropgeometrycolumn(table_name character varying, column_name character varying) FROM PUBLIC;


--
-- Name: FUNCTION dropgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.dropgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying) FROM PUBLIC;


--
-- Name: FUNCTION dropgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.dropgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying) FROM PUBLIC;


--
-- Name: FUNCTION dropgeometrytable(table_name character varying); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.dropgeometrytable(table_name character varying) FROM PUBLIC;


--
-- Name: FUNCTION dropgeometrytable(schema_name character varying, table_name character varying); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.dropgeometrytable(schema_name character varying, table_name character varying) FROM PUBLIC;


--
-- Name: FUNCTION dropgeometrytable(catalog_name character varying, schema_name character varying, table_name character varying); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.dropgeometrytable(catalog_name character varying, schema_name character varying, table_name character varying) FROM PUBLIC;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.encrypt(bytea, bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.encrypt_iv(bytea, bytea, bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION equals(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.equals(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: TABLE event; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE maevsi.event TO maevsi_account;
GRANT SELECT ON TABLE maevsi.event TO maevsi_anonymous;


--
-- Name: FUNCTION event_delete(id uuid, password text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.event_delete(id uuid, password text) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.event_delete(id uuid, password text) TO maevsi_account;


--
-- Name: FUNCTION event_distances(_account_id uuid, _max_distance double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.event_distances(_account_id uuid, _max_distance double precision) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.event_distances(_account_id uuid, _max_distance double precision) TO maevsi_account;


--
-- Name: FUNCTION event_invitee_count_maximum(event_id uuid); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.event_invitee_count_maximum(event_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.event_invitee_count_maximum(event_id uuid) TO maevsi_account;
GRANT ALL ON FUNCTION maevsi.event_invitee_count_maximum(event_id uuid) TO maevsi_anonymous;


--
-- Name: FUNCTION event_is_existing(author_account_id uuid, slug text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.event_is_existing(author_account_id uuid, slug text) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.event_is_existing(author_account_id uuid, slug text) TO maevsi_account;
GRANT ALL ON FUNCTION maevsi.event_is_existing(author_account_id uuid, slug text) TO maevsi_anonymous;


--
-- Name: FUNCTION event_location_update(_event_id uuid, _latitude double precision, _longitude double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.event_location_update(_event_id uuid, _latitude double precision, _longitude double precision) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.event_location_update(_event_id uuid, _latitude double precision, _longitude double precision) TO maevsi_account;


--
-- Name: FUNCTION event_unlock(invitation_id uuid); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.event_unlock(invitation_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.event_unlock(invitation_id uuid) TO maevsi_account;
GRANT ALL ON FUNCTION maevsi.event_unlock(invitation_id uuid) TO maevsi_anonymous;


--
-- Name: FUNCTION events_organized(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.events_organized() FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.events_organized() TO maevsi_account;
GRANT ALL ON FUNCTION maevsi.events_organized() TO maevsi_anonymous;


--
-- Name: FUNCTION find_srid(character varying, character varying, character varying); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.find_srid(character varying, character varying, character varying) FROM PUBLIC;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.gen_random_bytes(integer) FROM PUBLIC;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.gen_random_uuid() FROM PUBLIC;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.gen_salt(text) FROM PUBLIC;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.gen_salt(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION geog_brin_inclusion_add_value(internal, internal, internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geog_brin_inclusion_add_value(internal, internal, internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geography_cmp(maevsi.geography, maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_cmp(maevsi.geography, maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION geography_distance_knn(maevsi.geography, maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_distance_knn(maevsi.geography, maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION geography_eq(maevsi.geography, maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_eq(maevsi.geography, maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION geography_ge(maevsi.geography, maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_ge(maevsi.geography, maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION geography_gist_compress(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_gist_compress(internal) FROM PUBLIC;


--
-- Name: FUNCTION geography_gist_consistent(internal, maevsi.geography, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_gist_consistent(internal, maevsi.geography, integer) FROM PUBLIC;


--
-- Name: FUNCTION geography_gist_decompress(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_gist_decompress(internal) FROM PUBLIC;


--
-- Name: FUNCTION geography_gist_distance(internal, maevsi.geography, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_gist_distance(internal, maevsi.geography, integer) FROM PUBLIC;


--
-- Name: FUNCTION geography_gist_penalty(internal, internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_gist_penalty(internal, internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geography_gist_picksplit(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_gist_picksplit(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geography_gist_same(maevsi.box2d, maevsi.box2d, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_gist_same(maevsi.box2d, maevsi.box2d, internal) FROM PUBLIC;


--
-- Name: FUNCTION geography_gist_union(bytea, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_gist_union(bytea, internal) FROM PUBLIC;


--
-- Name: FUNCTION geography_gt(maevsi.geography, maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_gt(maevsi.geography, maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION geography_le(maevsi.geography, maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_le(maevsi.geography, maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION geography_lt(maevsi.geography, maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_lt(maevsi.geography, maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION geography_overlaps(maevsi.geography, maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_overlaps(maevsi.geography, maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION geography_spgist_choose_nd(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_spgist_choose_nd(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geography_spgist_compress_nd(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_spgist_compress_nd(internal) FROM PUBLIC;


--
-- Name: FUNCTION geography_spgist_config_nd(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_spgist_config_nd(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geography_spgist_inner_consistent_nd(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_spgist_inner_consistent_nd(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geography_spgist_leaf_consistent_nd(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_spgist_leaf_consistent_nd(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geography_spgist_picksplit_nd(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geography_spgist_picksplit_nd(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geom2d_brin_inclusion_add_value(internal, internal, internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geom2d_brin_inclusion_add_value(internal, internal, internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geom3d_brin_inclusion_add_value(internal, internal, internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geom3d_brin_inclusion_add_value(internal, internal, internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geom4d_brin_inclusion_add_value(internal, internal, internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geom4d_brin_inclusion_add_value(internal, internal, internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_above(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_above(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_below(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_below(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_cmp(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_cmp(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_contained_3d(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_contained_3d(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_contains(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_contains(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_contains_3d(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_contains_3d(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_contains_nd(maevsi.geometry, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_contains_nd(maevsi.geometry, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_distance_box(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_distance_box(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_distance_centroid(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_distance_centroid(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_distance_centroid_nd(maevsi.geometry, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_distance_centroid_nd(maevsi.geometry, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_distance_cpa(maevsi.geometry, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_distance_cpa(maevsi.geometry, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_eq(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_eq(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_ge(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_ge(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_gist_compress_2d(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_gist_compress_2d(internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_gist_compress_nd(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_gist_compress_nd(internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_gist_consistent_2d(internal, maevsi.geometry, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_gist_consistent_2d(internal, maevsi.geometry, integer) FROM PUBLIC;


--
-- Name: FUNCTION geometry_gist_consistent_nd(internal, maevsi.geometry, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_gist_consistent_nd(internal, maevsi.geometry, integer) FROM PUBLIC;


--
-- Name: FUNCTION geometry_gist_decompress_2d(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_gist_decompress_2d(internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_gist_decompress_nd(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_gist_decompress_nd(internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_gist_distance_2d(internal, maevsi.geometry, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_gist_distance_2d(internal, maevsi.geometry, integer) FROM PUBLIC;


--
-- Name: FUNCTION geometry_gist_distance_nd(internal, maevsi.geometry, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_gist_distance_nd(internal, maevsi.geometry, integer) FROM PUBLIC;


--
-- Name: FUNCTION geometry_gist_penalty_2d(internal, internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_gist_penalty_2d(internal, internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_gist_penalty_nd(internal, internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_gist_penalty_nd(internal, internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_gist_picksplit_2d(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_gist_picksplit_2d(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_gist_picksplit_nd(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_gist_picksplit_nd(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_gist_same_2d(geom1 maevsi.geometry, geom2 maevsi.geometry, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_gist_same_2d(geom1 maevsi.geometry, geom2 maevsi.geometry, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_gist_same_nd(maevsi.geometry, maevsi.geometry, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_gist_same_nd(maevsi.geometry, maevsi.geometry, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_gist_sortsupport_2d(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_gist_sortsupport_2d(internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_gist_union_2d(bytea, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_gist_union_2d(bytea, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_gist_union_nd(bytea, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_gist_union_nd(bytea, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_gt(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_gt(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_hash(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_hash(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_le(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_le(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_left(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_left(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_lt(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_lt(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_neq(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_neq(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_overabove(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_overabove(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_overbelow(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_overbelow(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_overlaps(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_overlaps(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_overlaps_3d(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_overlaps_3d(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_overlaps_nd(maevsi.geometry, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_overlaps_nd(maevsi.geometry, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_overleft(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_overleft(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_overright(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_overright(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_right(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_right(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_same(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_same(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_same_3d(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_same_3d(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_same_nd(maevsi.geometry, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_same_nd(maevsi.geometry, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_sortsupport(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_sortsupport(internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_spgist_choose_2d(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_spgist_choose_2d(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_spgist_choose_3d(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_spgist_choose_3d(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_spgist_choose_nd(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_spgist_choose_nd(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_spgist_compress_2d(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_spgist_compress_2d(internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_spgist_compress_3d(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_spgist_compress_3d(internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_spgist_compress_nd(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_spgist_compress_nd(internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_spgist_config_2d(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_spgist_config_2d(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_spgist_config_3d(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_spgist_config_3d(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_spgist_config_nd(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_spgist_config_nd(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_spgist_inner_consistent_2d(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_spgist_inner_consistent_2d(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_spgist_inner_consistent_3d(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_spgist_inner_consistent_3d(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_spgist_inner_consistent_nd(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_spgist_inner_consistent_nd(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_spgist_leaf_consistent_2d(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_spgist_leaf_consistent_2d(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_spgist_leaf_consistent_3d(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_spgist_leaf_consistent_3d(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_spgist_leaf_consistent_nd(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_spgist_leaf_consistent_nd(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_spgist_picksplit_2d(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_spgist_picksplit_2d(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_spgist_picksplit_3d(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_spgist_picksplit_3d(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_spgist_picksplit_nd(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_spgist_picksplit_nd(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION geometry_within(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_within(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometry_within_nd(maevsi.geometry, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometry_within_nd(maevsi.geometry, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION geometrytype(maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometrytype(maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION geometrytype(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geometrytype(maevsi.geometry) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.geometrytype(maevsi.geometry) TO maevsi_anonymous;
GRANT ALL ON FUNCTION maevsi.geometrytype(maevsi.geometry) TO maevsi_account;


--
-- Name: FUNCTION geomfromewkb(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geomfromewkb(bytea) FROM PUBLIC;


--
-- Name: FUNCTION geomfromewkt(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.geomfromewkt(text) FROM PUBLIC;


--
-- Name: FUNCTION get_account_location_coordinates(_account_id uuid); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.get_account_location_coordinates(_account_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.get_account_location_coordinates(_account_id uuid) TO maevsi_account;


--
-- Name: FUNCTION get_event_location_coordinates(_event_id uuid); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.get_event_location_coordinates(_event_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.get_event_location_coordinates(_event_id uuid) TO maevsi_account;


--
-- Name: FUNCTION get_proj4_from_srid(integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.get_proj4_from_srid(integer) FROM PUBLIC;


--
-- Name: FUNCTION gserialized_gist_joinsel_2d(internal, oid, internal, smallint); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.gserialized_gist_joinsel_2d(internal, oid, internal, smallint) FROM PUBLIC;


--
-- Name: FUNCTION gserialized_gist_joinsel_nd(internal, oid, internal, smallint); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.gserialized_gist_joinsel_nd(internal, oid, internal, smallint) FROM PUBLIC;


--
-- Name: FUNCTION gserialized_gist_sel_2d(internal, oid, internal, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.gserialized_gist_sel_2d(internal, oid, internal, integer) FROM PUBLIC;


--
-- Name: FUNCTION gserialized_gist_sel_nd(internal, oid, internal, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.gserialized_gist_sel_nd(internal, oid, internal, integer) FROM PUBLIC;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.hmac(bytea, bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.hmac(text, text, text) FROM PUBLIC;


--
-- Name: FUNCTION invitation_claim_array(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.invitation_claim_array() FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.invitation_claim_array() TO maevsi_account;
GRANT ALL ON FUNCTION maevsi.invitation_claim_array() TO maevsi_anonymous;


--
-- Name: FUNCTION invitation_contact_ids(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.invitation_contact_ids() FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.invitation_contact_ids() TO maevsi_account;
GRANT ALL ON FUNCTION maevsi.invitation_contact_ids() TO maevsi_anonymous;


--
-- Name: FUNCTION invite(invitation_id uuid, language text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.invite(invitation_id uuid, language text) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.invite(invitation_id uuid, language text) TO maevsi_account;


--
-- Name: FUNCTION invitee_count(event_id uuid); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.invitee_count(event_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.invitee_count(event_id uuid) TO maevsi_account;
GRANT ALL ON FUNCTION maevsi.invitee_count(event_id uuid) TO maevsi_anonymous;


--
-- Name: FUNCTION invoker_account_id(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.invoker_account_id() FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.invoker_account_id() TO maevsi_account;
GRANT ALL ON FUNCTION maevsi.invoker_account_id() TO maevsi_anonymous;


--
-- Name: FUNCTION is_contained_2d(maevsi.box2df, maevsi.box2df); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.is_contained_2d(maevsi.box2df, maevsi.box2df) FROM PUBLIC;


--
-- Name: FUNCTION is_contained_2d(maevsi.box2df, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.is_contained_2d(maevsi.box2df, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION is_contained_2d(maevsi.geometry, maevsi.box2df); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.is_contained_2d(maevsi.geometry, maevsi.box2df) FROM PUBLIC;


--
-- Name: FUNCTION jwt_refresh(jwt_id uuid); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.jwt_refresh(jwt_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.jwt_refresh(jwt_id uuid) TO maevsi_account;
GRANT ALL ON FUNCTION maevsi.jwt_refresh(jwt_id uuid) TO maevsi_anonymous;


--
-- Name: FUNCTION legal_term_change(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.legal_term_change() FROM PUBLIC;


--
-- Name: FUNCTION notification_acknowledge(id uuid, is_acknowledged boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.notification_acknowledge(id uuid, is_acknowledged boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.notification_acknowledge(id uuid, is_acknowledged boolean) TO maevsi_anonymous;


--
-- Name: FUNCTION overlaps_2d(maevsi.box2df, maevsi.box2df); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.overlaps_2d(maevsi.box2df, maevsi.box2df) FROM PUBLIC;


--
-- Name: FUNCTION overlaps_2d(maevsi.box2df, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.overlaps_2d(maevsi.box2df, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION overlaps_2d(maevsi.geometry, maevsi.box2df); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.overlaps_2d(maevsi.geometry, maevsi.box2df) FROM PUBLIC;


--
-- Name: FUNCTION overlaps_geog(maevsi.geography, maevsi.gidx); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.overlaps_geog(maevsi.geography, maevsi.gidx) FROM PUBLIC;


--
-- Name: FUNCTION overlaps_geog(maevsi.gidx, maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.overlaps_geog(maevsi.gidx, maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION overlaps_geog(maevsi.gidx, maevsi.gidx); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.overlaps_geog(maevsi.gidx, maevsi.gidx) FROM PUBLIC;


--
-- Name: FUNCTION overlaps_nd(maevsi.geometry, maevsi.gidx); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.overlaps_nd(maevsi.geometry, maevsi.gidx) FROM PUBLIC;


--
-- Name: FUNCTION overlaps_nd(maevsi.gidx, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.overlaps_nd(maevsi.gidx, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION overlaps_nd(maevsi.gidx, maevsi.gidx); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.overlaps_nd(maevsi.gidx, maevsi.gidx) FROM PUBLIC;


--
-- Name: FUNCTION pgis_asflatgeobuf_finalfn(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_asflatgeobuf_finalfn(internal) FROM PUBLIC;


--
-- Name: FUNCTION pgis_asflatgeobuf_transfn(internal, anyelement); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_asflatgeobuf_transfn(internal, anyelement) FROM PUBLIC;


--
-- Name: FUNCTION pgis_asflatgeobuf_transfn(internal, anyelement, boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_asflatgeobuf_transfn(internal, anyelement, boolean) FROM PUBLIC;


--
-- Name: FUNCTION pgis_asflatgeobuf_transfn(internal, anyelement, boolean, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_asflatgeobuf_transfn(internal, anyelement, boolean, text) FROM PUBLIC;


--
-- Name: FUNCTION pgis_asgeobuf_finalfn(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_asgeobuf_finalfn(internal) FROM PUBLIC;


--
-- Name: FUNCTION pgis_asgeobuf_transfn(internal, anyelement); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_asgeobuf_transfn(internal, anyelement) FROM PUBLIC;


--
-- Name: FUNCTION pgis_asgeobuf_transfn(internal, anyelement, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_asgeobuf_transfn(internal, anyelement, text) FROM PUBLIC;


--
-- Name: FUNCTION pgis_asmvt_combinefn(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_asmvt_combinefn(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION pgis_asmvt_deserialfn(bytea, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_asmvt_deserialfn(bytea, internal) FROM PUBLIC;


--
-- Name: FUNCTION pgis_asmvt_finalfn(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_asmvt_finalfn(internal) FROM PUBLIC;


--
-- Name: FUNCTION pgis_asmvt_serialfn(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_asmvt_serialfn(internal) FROM PUBLIC;


--
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_asmvt_transfn(internal, anyelement) FROM PUBLIC;


--
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_asmvt_transfn(internal, anyelement, text) FROM PUBLIC;


--
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement, text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_asmvt_transfn(internal, anyelement, text, integer) FROM PUBLIC;


--
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement, text, integer, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_asmvt_transfn(internal, anyelement, text, integer, text) FROM PUBLIC;


--
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement, text, integer, text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_asmvt_transfn(internal, anyelement, text, integer, text, text) FROM PUBLIC;


--
-- Name: FUNCTION pgis_geometry_accum_transfn(internal, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_geometry_accum_transfn(internal, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION pgis_geometry_accum_transfn(internal, maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_geometry_accum_transfn(internal, maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION pgis_geometry_accum_transfn(internal, maevsi.geometry, double precision, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_geometry_accum_transfn(internal, maevsi.geometry, double precision, integer) FROM PUBLIC;


--
-- Name: FUNCTION pgis_geometry_clusterintersecting_finalfn(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_geometry_clusterintersecting_finalfn(internal) FROM PUBLIC;


--
-- Name: FUNCTION pgis_geometry_clusterwithin_finalfn(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_geometry_clusterwithin_finalfn(internal) FROM PUBLIC;


--
-- Name: FUNCTION pgis_geometry_collect_finalfn(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_geometry_collect_finalfn(internal) FROM PUBLIC;


--
-- Name: FUNCTION pgis_geometry_coverageunion_finalfn(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_geometry_coverageunion_finalfn(internal) FROM PUBLIC;


--
-- Name: FUNCTION pgis_geometry_makeline_finalfn(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_geometry_makeline_finalfn(internal) FROM PUBLIC;


--
-- Name: FUNCTION pgis_geometry_polygonize_finalfn(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_geometry_polygonize_finalfn(internal) FROM PUBLIC;


--
-- Name: FUNCTION pgis_geometry_union_parallel_combinefn(internal, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_geometry_union_parallel_combinefn(internal, internal) FROM PUBLIC;


--
-- Name: FUNCTION pgis_geometry_union_parallel_deserialfn(bytea, internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_geometry_union_parallel_deserialfn(bytea, internal) FROM PUBLIC;


--
-- Name: FUNCTION pgis_geometry_union_parallel_finalfn(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_geometry_union_parallel_finalfn(internal) FROM PUBLIC;


--
-- Name: FUNCTION pgis_geometry_union_parallel_serialfn(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_geometry_union_parallel_serialfn(internal) FROM PUBLIC;


--
-- Name: FUNCTION pgis_geometry_union_parallel_transfn(internal, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_geometry_union_parallel_transfn(internal, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION pgis_geometry_union_parallel_transfn(internal, maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgis_geometry_union_parallel_transfn(internal, maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_armor_headers(text, OUT key text, OUT value text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_key_id(bytea) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_pub_decrypt(bytea, bytea) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_pub_decrypt(bytea, bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_pub_decrypt(bytea, bytea, text, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_pub_decrypt_bytea(bytea, bytea) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_pub_decrypt_bytea(bytea, bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_pub_decrypt_bytea(bytea, bytea, text, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_pub_encrypt(text, bytea) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_pub_encrypt(text, bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_pub_encrypt_bytea(bytea, bytea) FROM PUBLIC;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_pub_encrypt_bytea(bytea, bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_sym_decrypt(bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_sym_decrypt(bytea, text, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_sym_decrypt_bytea(bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_sym_decrypt_bytea(bytea, text, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_sym_encrypt(text, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_sym_encrypt(text, text, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_sym_encrypt_bytea(bytea, text) FROM PUBLIC;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.pgp_sym_encrypt_bytea(bytea, text, text) FROM PUBLIC;


--
-- Name: FUNCTION populate_geometry_columns(use_typmod boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.populate_geometry_columns(use_typmod boolean) FROM PUBLIC;


--
-- Name: FUNCTION populate_geometry_columns(tbl_oid oid, use_typmod boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.populate_geometry_columns(tbl_oid oid, use_typmod boolean) FROM PUBLIC;


--
-- Name: FUNCTION postgis_addbbox(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_addbbox(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION postgis_cache_bbox(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_cache_bbox() FROM PUBLIC;


--
-- Name: FUNCTION postgis_constraint_dims(geomschema text, geomtable text, geomcolumn text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_constraint_dims(geomschema text, geomtable text, geomcolumn text) FROM PUBLIC;


--
-- Name: FUNCTION postgis_constraint_srid(geomschema text, geomtable text, geomcolumn text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_constraint_srid(geomschema text, geomtable text, geomcolumn text) FROM PUBLIC;


--
-- Name: FUNCTION postgis_constraint_type(geomschema text, geomtable text, geomcolumn text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_constraint_type(geomschema text, geomtable text, geomcolumn text) FROM PUBLIC;


--
-- Name: FUNCTION postgis_dropbbox(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_dropbbox(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION postgis_extensions_upgrade(target_version text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_extensions_upgrade(target_version text) FROM PUBLIC;


--
-- Name: FUNCTION postgis_full_version(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_full_version() FROM PUBLIC;


--
-- Name: FUNCTION postgis_geos_compiled_version(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_geos_compiled_version() FROM PUBLIC;


--
-- Name: FUNCTION postgis_geos_noop(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_geos_noop(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION postgis_geos_version(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_geos_version() FROM PUBLIC;


--
-- Name: FUNCTION postgis_getbbox(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_getbbox(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION postgis_hasbbox(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_hasbbox(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION postgis_index_supportfn(internal); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_index_supportfn(internal) FROM PUBLIC;


--
-- Name: FUNCTION postgis_lib_build_date(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_lib_build_date() FROM PUBLIC;


--
-- Name: FUNCTION postgis_lib_revision(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_lib_revision() FROM PUBLIC;


--
-- Name: FUNCTION postgis_lib_version(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_lib_version() FROM PUBLIC;


--
-- Name: FUNCTION postgis_libjson_version(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_libjson_version() FROM PUBLIC;


--
-- Name: FUNCTION postgis_liblwgeom_version(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_liblwgeom_version() FROM PUBLIC;


--
-- Name: FUNCTION postgis_libprotobuf_version(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_libprotobuf_version() FROM PUBLIC;


--
-- Name: FUNCTION postgis_libxml_version(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_libxml_version() FROM PUBLIC;


--
-- Name: FUNCTION postgis_noop(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_noop(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION postgis_proj_compiled_version(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_proj_compiled_version() FROM PUBLIC;


--
-- Name: FUNCTION postgis_proj_version(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_proj_version() FROM PUBLIC;


--
-- Name: FUNCTION postgis_scripts_build_date(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_scripts_build_date() FROM PUBLIC;


--
-- Name: FUNCTION postgis_scripts_installed(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_scripts_installed() FROM PUBLIC;


--
-- Name: FUNCTION postgis_scripts_released(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_scripts_released() FROM PUBLIC;


--
-- Name: FUNCTION postgis_srs(auth_name text, auth_srid text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_srs(auth_name text, auth_srid text) FROM PUBLIC;


--
-- Name: FUNCTION postgis_srs_all(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_srs_all() FROM PUBLIC;


--
-- Name: FUNCTION postgis_srs_codes(auth_name text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_srs_codes(auth_name text) FROM PUBLIC;


--
-- Name: FUNCTION postgis_srs_search(bounds maevsi.geometry, authname text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_srs_search(bounds maevsi.geometry, authname text) FROM PUBLIC;


--
-- Name: FUNCTION postgis_svn_version(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_svn_version() FROM PUBLIC;


--
-- Name: FUNCTION postgis_transform_geometry(geom maevsi.geometry, text, text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_transform_geometry(geom maevsi.geometry, text, text, integer) FROM PUBLIC;


--
-- Name: FUNCTION postgis_transform_pipeline_geometry(geom maevsi.geometry, pipeline text, forward boolean, to_srid integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_transform_pipeline_geometry(geom maevsi.geometry, pipeline text, forward boolean, to_srid integer) FROM PUBLIC;


--
-- Name: FUNCTION postgis_type_name(geomname character varying, coord_dimension integer, use_new_name boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_type_name(geomname character varying, coord_dimension integer, use_new_name boolean) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.postgis_type_name(geomname character varying, coord_dimension integer, use_new_name boolean) TO maevsi_anonymous;
GRANT ALL ON FUNCTION maevsi.postgis_type_name(geomname character varying, coord_dimension integer, use_new_name boolean) TO maevsi_account;


--
-- Name: FUNCTION postgis_typmod_dims(integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_typmod_dims(integer) FROM PUBLIC;


--
-- Name: FUNCTION postgis_typmod_srid(integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_typmod_srid(integer) FROM PUBLIC;


--
-- Name: FUNCTION postgis_typmod_type(integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_typmod_type(integer) FROM PUBLIC;


--
-- Name: FUNCTION postgis_version(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_version() FROM PUBLIC;


--
-- Name: FUNCTION postgis_wagyu_version(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.postgis_wagyu_version() FROM PUBLIC;


--
-- Name: FUNCTION profile_picture_set(upload_id uuid); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.profile_picture_set(upload_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.profile_picture_set(upload_id uuid) TO maevsi_account;


--
-- Name: FUNCTION st_3dclosestpoint(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_3dclosestpoint(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_3ddfullywithin(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_3ddfullywithin(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_3ddistance(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_3ddistance(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_3ddwithin(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_3ddwithin(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_3dintersects(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_3dintersects(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_3dlength(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_3dlength(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_3dlineinterpolatepoint(maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_3dlineinterpolatepoint(maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_3dlongestline(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_3dlongestline(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_3dmakebox(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_3dmakebox(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_3dmaxdistance(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_3dmaxdistance(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_3dperimeter(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_3dperimeter(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_3dshortestline(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_3dshortestline(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_addmeasure(maevsi.geometry, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_addmeasure(maevsi.geometry, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_addpoint(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_addpoint(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_addpoint(geom1 maevsi.geometry, geom2 maevsi.geometry, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_addpoint(geom1 maevsi.geometry, geom2 maevsi.geometry, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_affine(maevsi.geometry, double precision, double precision, double precision, double precision, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_affine(maevsi.geometry, double precision, double precision, double precision, double precision, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_affine(maevsi.geometry, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_affine(maevsi.geometry, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_angle(line1 maevsi.geometry, line2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_angle(line1 maevsi.geometry, line2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_angle(pt1 maevsi.geometry, pt2 maevsi.geometry, pt3 maevsi.geometry, pt4 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_angle(pt1 maevsi.geometry, pt2 maevsi.geometry, pt3 maevsi.geometry, pt4 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_area(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_area(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_area(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_area(text) FROM PUBLIC;


--
-- Name: FUNCTION st_area(geog maevsi.geography, use_spheroid boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_area(geog maevsi.geography, use_spheroid boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_area2d(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_area2d(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_asbinary(maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asbinary(maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION st_asbinary(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asbinary(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_asbinary(maevsi.geography, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asbinary(maevsi.geography, text) FROM PUBLIC;


--
-- Name: FUNCTION st_asbinary(maevsi.geometry, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asbinary(maevsi.geometry, text) FROM PUBLIC;


--
-- Name: FUNCTION st_asencodedpolyline(geom maevsi.geometry, nprecision integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asencodedpolyline(geom maevsi.geometry, nprecision integer) FROM PUBLIC;


--
-- Name: FUNCTION st_asewkb(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asewkb(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_asewkb(maevsi.geometry, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asewkb(maevsi.geometry, text) FROM PUBLIC;


--
-- Name: FUNCTION st_asewkt(maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asewkt(maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION st_asewkt(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asewkt(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_asewkt(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asewkt(text) FROM PUBLIC;


--
-- Name: FUNCTION st_asewkt(maevsi.geography, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asewkt(maevsi.geography, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_asewkt(maevsi.geometry, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asewkt(maevsi.geometry, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_asgeojson(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asgeojson(text) FROM PUBLIC;


--
-- Name: FUNCTION st_asgeojson(geog maevsi.geography, maxdecimaldigits integer, options integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asgeojson(geog maevsi.geography, maxdecimaldigits integer, options integer) FROM PUBLIC;


--
-- Name: FUNCTION st_asgeojson(geom maevsi.geometry, maxdecimaldigits integer, options integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asgeojson(geom maevsi.geometry, maxdecimaldigits integer, options integer) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.st_asgeojson(geom maevsi.geometry, maxdecimaldigits integer, options integer) TO maevsi_anonymous;
GRANT ALL ON FUNCTION maevsi.st_asgeojson(geom maevsi.geometry, maxdecimaldigits integer, options integer) TO maevsi_account;


--
-- Name: FUNCTION st_asgeojson(r record, geom_column text, maxdecimaldigits integer, pretty_bool boolean, id_column text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asgeojson(r record, geom_column text, maxdecimaldigits integer, pretty_bool boolean, id_column text) FROM PUBLIC;


--
-- Name: FUNCTION st_asgml(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asgml(text) FROM PUBLIC;


--
-- Name: FUNCTION st_asgml(geom maevsi.geometry, maxdecimaldigits integer, options integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asgml(geom maevsi.geometry, maxdecimaldigits integer, options integer) FROM PUBLIC;


--
-- Name: FUNCTION st_asgml(geog maevsi.geography, maxdecimaldigits integer, options integer, nprefix text, id text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asgml(geog maevsi.geography, maxdecimaldigits integer, options integer, nprefix text, id text) FROM PUBLIC;


--
-- Name: FUNCTION st_asgml(version integer, geog maevsi.geography, maxdecimaldigits integer, options integer, nprefix text, id text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asgml(version integer, geog maevsi.geography, maxdecimaldigits integer, options integer, nprefix text, id text) FROM PUBLIC;


--
-- Name: FUNCTION st_asgml(version integer, geom maevsi.geometry, maxdecimaldigits integer, options integer, nprefix text, id text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asgml(version integer, geom maevsi.geometry, maxdecimaldigits integer, options integer, nprefix text, id text) FROM PUBLIC;


--
-- Name: FUNCTION st_ashexewkb(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_ashexewkb(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_ashexewkb(maevsi.geometry, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_ashexewkb(maevsi.geometry, text) FROM PUBLIC;


--
-- Name: FUNCTION st_askml(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_askml(text) FROM PUBLIC;


--
-- Name: FUNCTION st_askml(geog maevsi.geography, maxdecimaldigits integer, nprefix text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_askml(geog maevsi.geography, maxdecimaldigits integer, nprefix text) FROM PUBLIC;


--
-- Name: FUNCTION st_askml(geom maevsi.geometry, maxdecimaldigits integer, nprefix text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_askml(geom maevsi.geometry, maxdecimaldigits integer, nprefix text) FROM PUBLIC;


--
-- Name: FUNCTION st_aslatlontext(geom maevsi.geometry, tmpl text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_aslatlontext(geom maevsi.geometry, tmpl text) FROM PUBLIC;


--
-- Name: FUNCTION st_asmarc21(geom maevsi.geometry, format text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asmarc21(geom maevsi.geometry, format text) FROM PUBLIC;


--
-- Name: FUNCTION st_asmvtgeom(geom maevsi.geometry, bounds maevsi.box2d, extent integer, buffer integer, clip_geom boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asmvtgeom(geom maevsi.geometry, bounds maevsi.box2d, extent integer, buffer integer, clip_geom boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_assvg(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_assvg(text) FROM PUBLIC;


--
-- Name: FUNCTION st_assvg(geog maevsi.geography, rel integer, maxdecimaldigits integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_assvg(geog maevsi.geography, rel integer, maxdecimaldigits integer) FROM PUBLIC;


--
-- Name: FUNCTION st_assvg(geom maevsi.geometry, rel integer, maxdecimaldigits integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_assvg(geom maevsi.geometry, rel integer, maxdecimaldigits integer) FROM PUBLIC;


--
-- Name: FUNCTION st_astext(maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_astext(maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION st_astext(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_astext(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_astext(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_astext(text) FROM PUBLIC;


--
-- Name: FUNCTION st_astext(maevsi.geography, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_astext(maevsi.geography, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_astext(maevsi.geometry, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_astext(maevsi.geometry, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_astwkb(geom maevsi.geometry, prec integer, prec_z integer, prec_m integer, with_sizes boolean, with_boxes boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_astwkb(geom maevsi.geometry, prec integer, prec_z integer, prec_m integer, with_sizes boolean, with_boxes boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_astwkb(geom maevsi.geometry[], ids bigint[], prec integer, prec_z integer, prec_m integer, with_sizes boolean, with_boxes boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_astwkb(geom maevsi.geometry[], ids bigint[], prec integer, prec_z integer, prec_m integer, with_sizes boolean, with_boxes boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_asx3d(geom maevsi.geometry, maxdecimaldigits integer, options integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asx3d(geom maevsi.geometry, maxdecimaldigits integer, options integer) FROM PUBLIC;


--
-- Name: FUNCTION st_azimuth(geog1 maevsi.geography, geog2 maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_azimuth(geog1 maevsi.geography, geog2 maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION st_azimuth(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_azimuth(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_bdmpolyfromtext(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_bdmpolyfromtext(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_bdpolyfromtext(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_bdpolyfromtext(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_boundary(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_boundary(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_boundingdiagonal(geom maevsi.geometry, fits boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_boundingdiagonal(geom maevsi.geometry, fits boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_box2dfromgeohash(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_box2dfromgeohash(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_buffer(maevsi.geography, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_buffer(maevsi.geography, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_buffer(text, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_buffer(text, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_buffer(maevsi.geography, double precision, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_buffer(maevsi.geography, double precision, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_buffer(maevsi.geography, double precision, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_buffer(maevsi.geography, double precision, text) FROM PUBLIC;


--
-- Name: FUNCTION st_buffer(geom maevsi.geometry, radius double precision, quadsegs integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_buffer(geom maevsi.geometry, radius double precision, quadsegs integer) FROM PUBLIC;


--
-- Name: FUNCTION st_buffer(geom maevsi.geometry, radius double precision, options text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_buffer(geom maevsi.geometry, radius double precision, options text) FROM PUBLIC;


--
-- Name: FUNCTION st_buffer(text, double precision, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_buffer(text, double precision, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_buffer(text, double precision, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_buffer(text, double precision, text) FROM PUBLIC;


--
-- Name: FUNCTION st_buildarea(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_buildarea(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_centroid(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_centroid(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_centroid(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_centroid(text) FROM PUBLIC;


--
-- Name: FUNCTION st_centroid(maevsi.geography, use_spheroid boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_centroid(maevsi.geography, use_spheroid boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_chaikinsmoothing(maevsi.geometry, integer, boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_chaikinsmoothing(maevsi.geometry, integer, boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_cleangeometry(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_cleangeometry(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_clipbybox2d(geom maevsi.geometry, box maevsi.box2d); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_clipbybox2d(geom maevsi.geometry, box maevsi.box2d) FROM PUBLIC;


--
-- Name: FUNCTION st_closestpoint(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_closestpoint(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_closestpoint(text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_closestpoint(text, text) FROM PUBLIC;


--
-- Name: FUNCTION st_closestpoint(maevsi.geography, maevsi.geography, use_spheroid boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_closestpoint(maevsi.geography, maevsi.geography, use_spheroid boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_closestpointofapproach(maevsi.geometry, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_closestpointofapproach(maevsi.geometry, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_clusterdbscan(maevsi.geometry, eps double precision, minpoints integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_clusterdbscan(maevsi.geometry, eps double precision, minpoints integer) FROM PUBLIC;


--
-- Name: FUNCTION st_clusterintersecting(maevsi.geometry[]); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_clusterintersecting(maevsi.geometry[]) FROM PUBLIC;


--
-- Name: FUNCTION st_clusterintersectingwin(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_clusterintersectingwin(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_clusterkmeans(geom maevsi.geometry, k integer, max_radius double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_clusterkmeans(geom maevsi.geometry, k integer, max_radius double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_clusterwithin(maevsi.geometry[], double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_clusterwithin(maevsi.geometry[], double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_clusterwithinwin(maevsi.geometry, distance double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_clusterwithinwin(maevsi.geometry, distance double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_collect(maevsi.geometry[]); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_collect(maevsi.geometry[]) FROM PUBLIC;


--
-- Name: FUNCTION st_collect(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_collect(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_collectionextract(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_collectionextract(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_collectionextract(maevsi.geometry, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_collectionextract(maevsi.geometry, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_collectionhomogenize(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_collectionhomogenize(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_combinebbox(maevsi.box2d, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_combinebbox(maevsi.box2d, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_combinebbox(maevsi.box3d, maevsi.box3d); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_combinebbox(maevsi.box3d, maevsi.box3d) FROM PUBLIC;


--
-- Name: FUNCTION st_combinebbox(maevsi.box3d, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_combinebbox(maevsi.box3d, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_concavehull(param_geom maevsi.geometry, param_pctconvex double precision, param_allow_holes boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_concavehull(param_geom maevsi.geometry, param_pctconvex double precision, param_allow_holes boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_contains(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_contains(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_containsproperly(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_containsproperly(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_convexhull(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_convexhull(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_coorddim(geometry maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_coorddim(geometry maevsi.geometry) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.st_coorddim(geometry maevsi.geometry) TO maevsi_anonymous;
GRANT ALL ON FUNCTION maevsi.st_coorddim(geometry maevsi.geometry) TO maevsi_account;


--
-- Name: FUNCTION st_coverageinvalidedges(geom maevsi.geometry, tolerance double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_coverageinvalidedges(geom maevsi.geometry, tolerance double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_coveragesimplify(geom maevsi.geometry, tolerance double precision, simplifyboundary boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_coveragesimplify(geom maevsi.geometry, tolerance double precision, simplifyboundary boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_coverageunion(maevsi.geometry[]); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_coverageunion(maevsi.geometry[]) FROM PUBLIC;


--
-- Name: FUNCTION st_coveredby(geog1 maevsi.geography, geog2 maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_coveredby(geog1 maevsi.geography, geog2 maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION st_coveredby(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_coveredby(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_coveredby(text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_coveredby(text, text) FROM PUBLIC;


--
-- Name: FUNCTION st_covers(geog1 maevsi.geography, geog2 maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_covers(geog1 maevsi.geography, geog2 maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION st_covers(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_covers(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_covers(text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_covers(text, text) FROM PUBLIC;


--
-- Name: FUNCTION st_cpawithin(maevsi.geometry, maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_cpawithin(maevsi.geometry, maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_crosses(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_crosses(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_curven(geometry maevsi.geometry, i integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_curven(geometry maevsi.geometry, i integer) FROM PUBLIC;


--
-- Name: FUNCTION st_curvetoline(geom maevsi.geometry, tol double precision, toltype integer, flags integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_curvetoline(geom maevsi.geometry, tol double precision, toltype integer, flags integer) FROM PUBLIC;


--
-- Name: FUNCTION st_delaunaytriangles(g1 maevsi.geometry, tolerance double precision, flags integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_delaunaytriangles(g1 maevsi.geometry, tolerance double precision, flags integer) FROM PUBLIC;


--
-- Name: FUNCTION st_dfullywithin(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_dfullywithin(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_difference(geom1 maevsi.geometry, geom2 maevsi.geometry, gridsize double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_difference(geom1 maevsi.geometry, geom2 maevsi.geometry, gridsize double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_dimension(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_dimension(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_disjoint(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_disjoint(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_distance(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_distance(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_distance(text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_distance(text, text) FROM PUBLIC;


--
-- Name: FUNCTION st_distance(geog1 maevsi.geography, geog2 maevsi.geography, use_spheroid boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_distance(geog1 maevsi.geography, geog2 maevsi.geography, use_spheroid boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_distancecpa(maevsi.geometry, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_distancecpa(maevsi.geometry, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_distancesphere(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_distancesphere(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_distancesphere(geom1 maevsi.geometry, geom2 maevsi.geometry, radius double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_distancesphere(geom1 maevsi.geometry, geom2 maevsi.geometry, radius double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_distancespheroid(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_distancespheroid(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_distancespheroid(geom1 maevsi.geometry, geom2 maevsi.geometry, maevsi.spheroid); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_distancespheroid(geom1 maevsi.geometry, geom2 maevsi.geometry, maevsi.spheroid) FROM PUBLIC;


--
-- Name: FUNCTION st_dump(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_dump(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_dumppoints(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_dumppoints(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_dumprings(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_dumprings(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_dumpsegments(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_dumpsegments(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_dwithin(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_dwithin(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_dwithin(text, text, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_dwithin(text, text, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_dwithin(geog1 maevsi.geography, geog2 maevsi.geography, tolerance double precision, use_spheroid boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_dwithin(geog1 maevsi.geography, geog2 maevsi.geography, tolerance double precision, use_spheroid boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_endpoint(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_endpoint(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_envelope(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_envelope(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_equals(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_equals(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_estimatedextent(text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_estimatedextent(text, text) FROM PUBLIC;


--
-- Name: FUNCTION st_estimatedextent(text, text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_estimatedextent(text, text, text) FROM PUBLIC;


--
-- Name: FUNCTION st_estimatedextent(text, text, text, boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_estimatedextent(text, text, text, boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_expand(maevsi.box2d, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_expand(maevsi.box2d, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_expand(maevsi.box3d, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_expand(maevsi.box3d, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_expand(maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_expand(maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_expand(box maevsi.box2d, dx double precision, dy double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_expand(box maevsi.box2d, dx double precision, dy double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_expand(box maevsi.box3d, dx double precision, dy double precision, dz double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_expand(box maevsi.box3d, dx double precision, dy double precision, dz double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_expand(geom maevsi.geometry, dx double precision, dy double precision, dz double precision, dm double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_expand(geom maevsi.geometry, dx double precision, dy double precision, dz double precision, dm double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_exteriorring(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_exteriorring(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_filterbym(maevsi.geometry, double precision, double precision, boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_filterbym(maevsi.geometry, double precision, double precision, boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_findextent(text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_findextent(text, text) FROM PUBLIC;


--
-- Name: FUNCTION st_findextent(text, text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_findextent(text, text, text) FROM PUBLIC;


--
-- Name: FUNCTION st_flipcoordinates(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_flipcoordinates(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_force2d(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_force2d(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_force3d(geom maevsi.geometry, zvalue double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_force3d(geom maevsi.geometry, zvalue double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_force3dm(geom maevsi.geometry, mvalue double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_force3dm(geom maevsi.geometry, mvalue double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_force3dz(geom maevsi.geometry, zvalue double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_force3dz(geom maevsi.geometry, zvalue double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_force4d(geom maevsi.geometry, zvalue double precision, mvalue double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_force4d(geom maevsi.geometry, zvalue double precision, mvalue double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_forcecollection(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_forcecollection(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_forcecurve(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_forcecurve(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_forcepolygonccw(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_forcepolygonccw(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_forcepolygoncw(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_forcepolygoncw(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_forcerhr(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_forcerhr(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_forcesfs(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_forcesfs(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_forcesfs(maevsi.geometry, version text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_forcesfs(maevsi.geometry, version text) FROM PUBLIC;


--
-- Name: FUNCTION st_frechetdistance(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_frechetdistance(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_fromflatgeobuf(anyelement, bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_fromflatgeobuf(anyelement, bytea) FROM PUBLIC;


--
-- Name: FUNCTION st_fromflatgeobuftotable(text, text, bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_fromflatgeobuftotable(text, text, bytea) FROM PUBLIC;


--
-- Name: FUNCTION st_generatepoints(area maevsi.geometry, npoints integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_generatepoints(area maevsi.geometry, npoints integer) FROM PUBLIC;


--
-- Name: FUNCTION st_generatepoints(area maevsi.geometry, npoints integer, seed integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_generatepoints(area maevsi.geometry, npoints integer, seed integer) FROM PUBLIC;


--
-- Name: FUNCTION st_geogfromtext(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geogfromtext(text) FROM PUBLIC;


--
-- Name: FUNCTION st_geogfromwkb(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geogfromwkb(bytea) FROM PUBLIC;


--
-- Name: FUNCTION st_geographyfromtext(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geographyfromtext(text) FROM PUBLIC;


--
-- Name: FUNCTION st_geohash(geog maevsi.geography, maxchars integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geohash(geog maevsi.geography, maxchars integer) FROM PUBLIC;


--
-- Name: FUNCTION st_geohash(geom maevsi.geometry, maxchars integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geohash(geom maevsi.geometry, maxchars integer) FROM PUBLIC;


--
-- Name: FUNCTION st_geomcollfromtext(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geomcollfromtext(text) FROM PUBLIC;


--
-- Name: FUNCTION st_geomcollfromtext(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geomcollfromtext(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_geomcollfromwkb(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geomcollfromwkb(bytea) FROM PUBLIC;


--
-- Name: FUNCTION st_geomcollfromwkb(bytea, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geomcollfromwkb(bytea, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_geometricmedian(g maevsi.geometry, tolerance double precision, max_iter integer, fail_if_not_converged boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geometricmedian(g maevsi.geometry, tolerance double precision, max_iter integer, fail_if_not_converged boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_geometryfromtext(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geometryfromtext(text) FROM PUBLIC;


--
-- Name: FUNCTION st_geometryfromtext(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geometryfromtext(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_geometryn(maevsi.geometry, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geometryn(maevsi.geometry, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_geometrytype(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geometrytype(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_geomfromewkb(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geomfromewkb(bytea) FROM PUBLIC;


--
-- Name: FUNCTION st_geomfromewkt(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geomfromewkt(text) FROM PUBLIC;


--
-- Name: FUNCTION st_geomfromgeohash(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geomfromgeohash(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_geomfromgeojson(json); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geomfromgeojson(json) FROM PUBLIC;


--
-- Name: FUNCTION st_geomfromgeojson(jsonb); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geomfromgeojson(jsonb) FROM PUBLIC;


--
-- Name: FUNCTION st_geomfromgeojson(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geomfromgeojson(text) FROM PUBLIC;


--
-- Name: FUNCTION st_geomfromgml(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geomfromgml(text) FROM PUBLIC;


--
-- Name: FUNCTION st_geomfromgml(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geomfromgml(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_geomfromkml(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geomfromkml(text) FROM PUBLIC;


--
-- Name: FUNCTION st_geomfrommarc21(marc21xml text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geomfrommarc21(marc21xml text) FROM PUBLIC;


--
-- Name: FUNCTION st_geomfromtext(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geomfromtext(text) FROM PUBLIC;


--
-- Name: FUNCTION st_geomfromtext(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geomfromtext(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_geomfromtwkb(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geomfromtwkb(bytea) FROM PUBLIC;


--
-- Name: FUNCTION st_geomfromwkb(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geomfromwkb(bytea) FROM PUBLIC;


--
-- Name: FUNCTION st_geomfromwkb(bytea, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_geomfromwkb(bytea, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_gmltosql(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_gmltosql(text) FROM PUBLIC;


--
-- Name: FUNCTION st_gmltosql(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_gmltosql(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_hasarc(geometry maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_hasarc(geometry maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_hasm(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_hasm(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_hasz(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_hasz(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_hausdorffdistance(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_hausdorffdistance(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_hausdorffdistance(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_hausdorffdistance(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_hexagon(size double precision, cell_i integer, cell_j integer, origin maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_hexagon(size double precision, cell_i integer, cell_j integer, origin maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_hexagongrid(size double precision, bounds maevsi.geometry, OUT geom maevsi.geometry, OUT i integer, OUT j integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_hexagongrid(size double precision, bounds maevsi.geometry, OUT geom maevsi.geometry, OUT i integer, OUT j integer) FROM PUBLIC;


--
-- Name: FUNCTION st_interiorringn(maevsi.geometry, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_interiorringn(maevsi.geometry, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_interpolatepoint(line maevsi.geometry, point maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_interpolatepoint(line maevsi.geometry, point maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_intersection(maevsi.geography, maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_intersection(maevsi.geography, maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION st_intersection(text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_intersection(text, text) FROM PUBLIC;


--
-- Name: FUNCTION st_intersection(geom1 maevsi.geometry, geom2 maevsi.geometry, gridsize double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_intersection(geom1 maevsi.geometry, geom2 maevsi.geometry, gridsize double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_intersects(geog1 maevsi.geography, geog2 maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_intersects(geog1 maevsi.geography, geog2 maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION st_intersects(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_intersects(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_intersects(text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_intersects(text, text) FROM PUBLIC;


--
-- Name: FUNCTION st_inversetransformpipeline(geom maevsi.geometry, pipeline text, to_srid integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_inversetransformpipeline(geom maevsi.geometry, pipeline text, to_srid integer) FROM PUBLIC;


--
-- Name: FUNCTION st_isclosed(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_isclosed(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_iscollection(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_iscollection(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_isempty(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_isempty(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_ispolygonccw(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_ispolygonccw(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_ispolygoncw(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_ispolygoncw(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_isring(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_isring(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_issimple(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_issimple(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_isvalid(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_isvalid(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_isvalid(maevsi.geometry, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_isvalid(maevsi.geometry, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_isvaliddetail(geom maevsi.geometry, flags integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_isvaliddetail(geom maevsi.geometry, flags integer) FROM PUBLIC;


--
-- Name: FUNCTION st_isvalidreason(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_isvalidreason(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_isvalidreason(maevsi.geometry, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_isvalidreason(maevsi.geometry, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_isvalidtrajectory(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_isvalidtrajectory(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_largestemptycircle(geom maevsi.geometry, tolerance double precision, boundary maevsi.geometry, OUT center maevsi.geometry, OUT nearest maevsi.geometry, OUT radius double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_largestemptycircle(geom maevsi.geometry, tolerance double precision, boundary maevsi.geometry, OUT center maevsi.geometry, OUT nearest maevsi.geometry, OUT radius double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_length(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_length(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_length(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_length(text) FROM PUBLIC;


--
-- Name: FUNCTION st_length(geog maevsi.geography, use_spheroid boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_length(geog maevsi.geography, use_spheroid boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_length2d(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_length2d(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_length2dspheroid(maevsi.geometry, maevsi.spheroid); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_length2dspheroid(maevsi.geometry, maevsi.spheroid) FROM PUBLIC;


--
-- Name: FUNCTION st_lengthspheroid(maevsi.geometry, maevsi.spheroid); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_lengthspheroid(maevsi.geometry, maevsi.spheroid) FROM PUBLIC;


--
-- Name: FUNCTION st_letters(letters text, font json); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_letters(letters text, font json) FROM PUBLIC;


--
-- Name: FUNCTION st_linecrossingdirection(line1 maevsi.geometry, line2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_linecrossingdirection(line1 maevsi.geometry, line2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_lineextend(geom maevsi.geometry, distance_forward double precision, distance_backward double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_lineextend(geom maevsi.geometry, distance_forward double precision, distance_backward double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_linefromencodedpolyline(txtin text, nprecision integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_linefromencodedpolyline(txtin text, nprecision integer) FROM PUBLIC;


--
-- Name: FUNCTION st_linefrommultipoint(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_linefrommultipoint(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_linefromtext(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_linefromtext(text) FROM PUBLIC;


--
-- Name: FUNCTION st_linefromtext(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_linefromtext(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_linefromwkb(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_linefromwkb(bytea) FROM PUBLIC;


--
-- Name: FUNCTION st_linefromwkb(bytea, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_linefromwkb(bytea, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_lineinterpolatepoint(maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_lineinterpolatepoint(maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_lineinterpolatepoint(text, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_lineinterpolatepoint(text, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_lineinterpolatepoint(maevsi.geography, double precision, use_spheroid boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_lineinterpolatepoint(maevsi.geography, double precision, use_spheroid boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_lineinterpolatepoints(text, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_lineinterpolatepoints(text, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_lineinterpolatepoints(maevsi.geometry, double precision, repeat boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_lineinterpolatepoints(maevsi.geometry, double precision, repeat boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_lineinterpolatepoints(maevsi.geography, double precision, use_spheroid boolean, repeat boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_lineinterpolatepoints(maevsi.geography, double precision, use_spheroid boolean, repeat boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_linelocatepoint(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_linelocatepoint(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_linelocatepoint(text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_linelocatepoint(text, text) FROM PUBLIC;


--
-- Name: FUNCTION st_linelocatepoint(maevsi.geography, maevsi.geography, use_spheroid boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_linelocatepoint(maevsi.geography, maevsi.geography, use_spheroid boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_linemerge(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_linemerge(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_linemerge(maevsi.geometry, boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_linemerge(maevsi.geometry, boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_linestringfromwkb(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_linestringfromwkb(bytea) FROM PUBLIC;


--
-- Name: FUNCTION st_linestringfromwkb(bytea, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_linestringfromwkb(bytea, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_linesubstring(maevsi.geography, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_linesubstring(maevsi.geography, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_linesubstring(maevsi.geometry, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_linesubstring(maevsi.geometry, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_linesubstring(text, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_linesubstring(text, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_linetocurve(geometry maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_linetocurve(geometry maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_locatealong(geometry maevsi.geometry, measure double precision, leftrightoffset double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_locatealong(geometry maevsi.geometry, measure double precision, leftrightoffset double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_locatebetween(geometry maevsi.geometry, frommeasure double precision, tomeasure double precision, leftrightoffset double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_locatebetween(geometry maevsi.geometry, frommeasure double precision, tomeasure double precision, leftrightoffset double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_locatebetweenelevations(geometry maevsi.geometry, fromelevation double precision, toelevation double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_locatebetweenelevations(geometry maevsi.geometry, fromelevation double precision, toelevation double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_longestline(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_longestline(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_m(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_m(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_makebox2d(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_makebox2d(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_makeenvelope(double precision, double precision, double precision, double precision, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_makeenvelope(double precision, double precision, double precision, double precision, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_makeline(maevsi.geometry[]); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_makeline(maevsi.geometry[]) FROM PUBLIC;


--
-- Name: FUNCTION st_makeline(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_makeline(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_makepoint(double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_makepoint(double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_makepoint(double precision, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_makepoint(double precision, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_makepoint(double precision, double precision, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_makepoint(double precision, double precision, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_makepointm(double precision, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_makepointm(double precision, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_makepolygon(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_makepolygon(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_makepolygon(maevsi.geometry, maevsi.geometry[]); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_makepolygon(maevsi.geometry, maevsi.geometry[]) FROM PUBLIC;


--
-- Name: FUNCTION st_makevalid(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_makevalid(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_makevalid(geom maevsi.geometry, params text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_makevalid(geom maevsi.geometry, params text) FROM PUBLIC;


--
-- Name: FUNCTION st_maxdistance(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_maxdistance(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_maximuminscribedcircle(maevsi.geometry, OUT center maevsi.geometry, OUT nearest maevsi.geometry, OUT radius double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_maximuminscribedcircle(maevsi.geometry, OUT center maevsi.geometry, OUT nearest maevsi.geometry, OUT radius double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_memsize(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_memsize(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_minimumboundingcircle(inputgeom maevsi.geometry, segs_per_quarter integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_minimumboundingcircle(inputgeom maevsi.geometry, segs_per_quarter integer) FROM PUBLIC;


--
-- Name: FUNCTION st_minimumboundingradius(maevsi.geometry, OUT center maevsi.geometry, OUT radius double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_minimumboundingradius(maevsi.geometry, OUT center maevsi.geometry, OUT radius double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_minimumclearance(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_minimumclearance(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_minimumclearanceline(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_minimumclearanceline(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_mlinefromtext(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_mlinefromtext(text) FROM PUBLIC;


--
-- Name: FUNCTION st_mlinefromtext(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_mlinefromtext(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_mlinefromwkb(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_mlinefromwkb(bytea) FROM PUBLIC;


--
-- Name: FUNCTION st_mlinefromwkb(bytea, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_mlinefromwkb(bytea, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_mpointfromtext(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_mpointfromtext(text) FROM PUBLIC;


--
-- Name: FUNCTION st_mpointfromtext(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_mpointfromtext(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_mpointfromwkb(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_mpointfromwkb(bytea) FROM PUBLIC;


--
-- Name: FUNCTION st_mpointfromwkb(bytea, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_mpointfromwkb(bytea, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_mpolyfromtext(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_mpolyfromtext(text) FROM PUBLIC;


--
-- Name: FUNCTION st_mpolyfromtext(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_mpolyfromtext(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_mpolyfromwkb(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_mpolyfromwkb(bytea) FROM PUBLIC;


--
-- Name: FUNCTION st_mpolyfromwkb(bytea, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_mpolyfromwkb(bytea, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_multi(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_multi(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_multilinefromwkb(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_multilinefromwkb(bytea) FROM PUBLIC;


--
-- Name: FUNCTION st_multilinestringfromtext(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_multilinestringfromtext(text) FROM PUBLIC;


--
-- Name: FUNCTION st_multilinestringfromtext(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_multilinestringfromtext(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_multipointfromtext(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_multipointfromtext(text) FROM PUBLIC;


--
-- Name: FUNCTION st_multipointfromwkb(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_multipointfromwkb(bytea) FROM PUBLIC;


--
-- Name: FUNCTION st_multipointfromwkb(bytea, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_multipointfromwkb(bytea, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_multipolyfromwkb(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_multipolyfromwkb(bytea) FROM PUBLIC;


--
-- Name: FUNCTION st_multipolyfromwkb(bytea, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_multipolyfromwkb(bytea, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_multipolygonfromtext(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_multipolygonfromtext(text) FROM PUBLIC;


--
-- Name: FUNCTION st_multipolygonfromtext(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_multipolygonfromtext(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_ndims(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_ndims(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_node(g maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_node(g maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_normalize(geom maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_normalize(geom maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_npoints(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_npoints(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_nrings(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_nrings(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_numcurves(geometry maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_numcurves(geometry maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_numgeometries(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_numgeometries(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_numinteriorring(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_numinteriorring(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_numinteriorrings(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_numinteriorrings(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_numpatches(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_numpatches(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_numpoints(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_numpoints(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_offsetcurve(line maevsi.geometry, distance double precision, params text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_offsetcurve(line maevsi.geometry, distance double precision, params text) FROM PUBLIC;


--
-- Name: FUNCTION st_orderingequals(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_orderingequals(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_orientedenvelope(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_orientedenvelope(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_overlaps(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_overlaps(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_patchn(maevsi.geometry, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_patchn(maevsi.geometry, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_perimeter(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_perimeter(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_perimeter(geog maevsi.geography, use_spheroid boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_perimeter(geog maevsi.geography, use_spheroid boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_perimeter2d(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_perimeter2d(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_point(double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_point(double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_point(double precision, double precision, srid integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_point(double precision, double precision, srid integer) FROM PUBLIC;


--
-- Name: FUNCTION st_pointfromgeohash(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_pointfromgeohash(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_pointfromtext(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_pointfromtext(text) FROM PUBLIC;


--
-- Name: FUNCTION st_pointfromtext(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_pointfromtext(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_pointfromwkb(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_pointfromwkb(bytea) FROM PUBLIC;


--
-- Name: FUNCTION st_pointfromwkb(bytea, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_pointfromwkb(bytea, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_pointinsidecircle(maevsi.geometry, double precision, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_pointinsidecircle(maevsi.geometry, double precision, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_pointm(xcoordinate double precision, ycoordinate double precision, mcoordinate double precision, srid integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_pointm(xcoordinate double precision, ycoordinate double precision, mcoordinate double precision, srid integer) FROM PUBLIC;


--
-- Name: FUNCTION st_pointn(maevsi.geometry, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_pointn(maevsi.geometry, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_pointonsurface(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_pointonsurface(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_points(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_points(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_pointz(xcoordinate double precision, ycoordinate double precision, zcoordinate double precision, srid integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_pointz(xcoordinate double precision, ycoordinate double precision, zcoordinate double precision, srid integer) FROM PUBLIC;


--
-- Name: FUNCTION st_pointzm(xcoordinate double precision, ycoordinate double precision, zcoordinate double precision, mcoordinate double precision, srid integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_pointzm(xcoordinate double precision, ycoordinate double precision, zcoordinate double precision, mcoordinate double precision, srid integer) FROM PUBLIC;


--
-- Name: FUNCTION st_polyfromtext(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_polyfromtext(text) FROM PUBLIC;


--
-- Name: FUNCTION st_polyfromtext(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_polyfromtext(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_polyfromwkb(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_polyfromwkb(bytea) FROM PUBLIC;


--
-- Name: FUNCTION st_polyfromwkb(bytea, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_polyfromwkb(bytea, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_polygon(maevsi.geometry, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_polygon(maevsi.geometry, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_polygonfromtext(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_polygonfromtext(text) FROM PUBLIC;


--
-- Name: FUNCTION st_polygonfromtext(text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_polygonfromtext(text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_polygonfromwkb(bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_polygonfromwkb(bytea) FROM PUBLIC;


--
-- Name: FUNCTION st_polygonfromwkb(bytea, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_polygonfromwkb(bytea, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_polygonize(maevsi.geometry[]); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_polygonize(maevsi.geometry[]) FROM PUBLIC;


--
-- Name: FUNCTION st_project(geog_from maevsi.geography, geog_to maevsi.geography, distance double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_project(geog_from maevsi.geography, geog_to maevsi.geography, distance double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_project(geog maevsi.geography, distance double precision, azimuth double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_project(geog maevsi.geography, distance double precision, azimuth double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_project(geom1 maevsi.geometry, geom2 maevsi.geometry, distance double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_project(geom1 maevsi.geometry, geom2 maevsi.geometry, distance double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_project(geom1 maevsi.geometry, distance double precision, azimuth double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_project(geom1 maevsi.geometry, distance double precision, azimuth double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_quantizecoordinates(g maevsi.geometry, prec_x integer, prec_y integer, prec_z integer, prec_m integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_quantizecoordinates(g maevsi.geometry, prec_x integer, prec_y integer, prec_z integer, prec_m integer) FROM PUBLIC;


--
-- Name: FUNCTION st_reduceprecision(geom maevsi.geometry, gridsize double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_reduceprecision(geom maevsi.geometry, gridsize double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_relate(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_relate(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_relate(geom1 maevsi.geometry, geom2 maevsi.geometry, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_relate(geom1 maevsi.geometry, geom2 maevsi.geometry, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_relate(geom1 maevsi.geometry, geom2 maevsi.geometry, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_relate(geom1 maevsi.geometry, geom2 maevsi.geometry, text) FROM PUBLIC;


--
-- Name: FUNCTION st_relatematch(text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_relatematch(text, text) FROM PUBLIC;


--
-- Name: FUNCTION st_removeirrelevantpointsforview(maevsi.geometry, maevsi.box2d, boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_removeirrelevantpointsforview(maevsi.geometry, maevsi.box2d, boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_removepoint(maevsi.geometry, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_removepoint(maevsi.geometry, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_removerepeatedpoints(geom maevsi.geometry, tolerance double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_removerepeatedpoints(geom maevsi.geometry, tolerance double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_removesmallparts(maevsi.geometry, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_removesmallparts(maevsi.geometry, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_reverse(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_reverse(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_rotate(maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_rotate(maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_rotate(maevsi.geometry, double precision, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_rotate(maevsi.geometry, double precision, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_rotate(maevsi.geometry, double precision, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_rotate(maevsi.geometry, double precision, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_rotatex(maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_rotatex(maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_rotatey(maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_rotatey(maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_rotatez(maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_rotatez(maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_scale(maevsi.geometry, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_scale(maevsi.geometry, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_scale(maevsi.geometry, maevsi.geometry, origin maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_scale(maevsi.geometry, maevsi.geometry, origin maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_scale(maevsi.geometry, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_scale(maevsi.geometry, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_scale(maevsi.geometry, double precision, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_scale(maevsi.geometry, double precision, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_scroll(maevsi.geometry, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_scroll(maevsi.geometry, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_segmentize(geog maevsi.geography, max_segment_length double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_segmentize(geog maevsi.geography, max_segment_length double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_segmentize(maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_segmentize(maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_seteffectivearea(maevsi.geometry, double precision, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_seteffectivearea(maevsi.geometry, double precision, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_setpoint(maevsi.geometry, integer, maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_setpoint(maevsi.geometry, integer, maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_setsrid(geog maevsi.geography, srid integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_setsrid(geog maevsi.geography, srid integer) FROM PUBLIC;


--
-- Name: FUNCTION st_setsrid(geom maevsi.geometry, srid integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_setsrid(geom maevsi.geometry, srid integer) FROM PUBLIC;


--
-- Name: FUNCTION st_sharedpaths(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_sharedpaths(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_shiftlongitude(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_shiftlongitude(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_shortestline(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_shortestline(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_shortestline(text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_shortestline(text, text) FROM PUBLIC;


--
-- Name: FUNCTION st_shortestline(maevsi.geography, maevsi.geography, use_spheroid boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_shortestline(maevsi.geography, maevsi.geography, use_spheroid boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_simplify(maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_simplify(maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_simplify(maevsi.geometry, double precision, boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_simplify(maevsi.geometry, double precision, boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_simplifypolygonhull(geom maevsi.geometry, vertex_fraction double precision, is_outer boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_simplifypolygonhull(geom maevsi.geometry, vertex_fraction double precision, is_outer boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_simplifypreservetopology(maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_simplifypreservetopology(maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_simplifyvw(maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_simplifyvw(maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_snap(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_snap(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_snaptogrid(maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_snaptogrid(maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_snaptogrid(maevsi.geometry, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_snaptogrid(maevsi.geometry, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_snaptogrid(maevsi.geometry, double precision, double precision, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_snaptogrid(maevsi.geometry, double precision, double precision, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_snaptogrid(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision, double precision, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_snaptogrid(geom1 maevsi.geometry, geom2 maevsi.geometry, double precision, double precision, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_split(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_split(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_square(size double precision, cell_i integer, cell_j integer, origin maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_square(size double precision, cell_i integer, cell_j integer, origin maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_squaregrid(size double precision, bounds maevsi.geometry, OUT geom maevsi.geometry, OUT i integer, OUT j integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_squaregrid(size double precision, bounds maevsi.geometry, OUT geom maevsi.geometry, OUT i integer, OUT j integer) FROM PUBLIC;


--
-- Name: FUNCTION st_srid(geog maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_srid(geog maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION st_srid(geom maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_srid(geom maevsi.geometry) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.st_srid(geom maevsi.geometry) TO maevsi_anonymous;
GRANT ALL ON FUNCTION maevsi.st_srid(geom maevsi.geometry) TO maevsi_account;


--
-- Name: FUNCTION st_startpoint(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_startpoint(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_subdivide(geom maevsi.geometry, maxvertices integer, gridsize double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_subdivide(geom maevsi.geometry, maxvertices integer, gridsize double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_summary(maevsi.geography); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_summary(maevsi.geography) FROM PUBLIC;


--
-- Name: FUNCTION st_summary(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_summary(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_swapordinates(geom maevsi.geometry, ords cstring); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_swapordinates(geom maevsi.geometry, ords cstring) FROM PUBLIC;


--
-- Name: FUNCTION st_symdifference(geom1 maevsi.geometry, geom2 maevsi.geometry, gridsize double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_symdifference(geom1 maevsi.geometry, geom2 maevsi.geometry, gridsize double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_symmetricdifference(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_symmetricdifference(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_tileenvelope(zoom integer, x integer, y integer, bounds maevsi.geometry, margin double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_tileenvelope(zoom integer, x integer, y integer, bounds maevsi.geometry, margin double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_touches(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_touches(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_transform(maevsi.geometry, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_transform(maevsi.geometry, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_transform(geom maevsi.geometry, to_proj text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_transform(geom maevsi.geometry, to_proj text) FROM PUBLIC;


--
-- Name: FUNCTION st_transform(geom maevsi.geometry, from_proj text, to_srid integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_transform(geom maevsi.geometry, from_proj text, to_srid integer) FROM PUBLIC;


--
-- Name: FUNCTION st_transform(geom maevsi.geometry, from_proj text, to_proj text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_transform(geom maevsi.geometry, from_proj text, to_proj text) FROM PUBLIC;


--
-- Name: FUNCTION st_transformpipeline(geom maevsi.geometry, pipeline text, to_srid integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_transformpipeline(geom maevsi.geometry, pipeline text, to_srid integer) FROM PUBLIC;


--
-- Name: FUNCTION st_translate(maevsi.geometry, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_translate(maevsi.geometry, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_translate(maevsi.geometry, double precision, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_translate(maevsi.geometry, double precision, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_transscale(maevsi.geometry, double precision, double precision, double precision, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_transscale(maevsi.geometry, double precision, double precision, double precision, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_triangulatepolygon(g1 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_triangulatepolygon(g1 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_unaryunion(maevsi.geometry, gridsize double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_unaryunion(maevsi.geometry, gridsize double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_union(maevsi.geometry[]); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_union(maevsi.geometry[]) FROM PUBLIC;


--
-- Name: FUNCTION st_union(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_union(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_union(geom1 maevsi.geometry, geom2 maevsi.geometry, gridsize double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_union(geom1 maevsi.geometry, geom2 maevsi.geometry, gridsize double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_voronoilines(g1 maevsi.geometry, tolerance double precision, extend_to maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_voronoilines(g1 maevsi.geometry, tolerance double precision, extend_to maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_voronoipolygons(g1 maevsi.geometry, tolerance double precision, extend_to maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_voronoipolygons(g1 maevsi.geometry, tolerance double precision, extend_to maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_within(geom1 maevsi.geometry, geom2 maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_within(geom1 maevsi.geometry, geom2 maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_wkbtosql(wkb bytea); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_wkbtosql(wkb bytea) FROM PUBLIC;


--
-- Name: FUNCTION st_wkttosql(text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_wkttosql(text) FROM PUBLIC;


--
-- Name: FUNCTION st_wrapx(geom maevsi.geometry, wrap double precision, move double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_wrapx(geom maevsi.geometry, wrap double precision, move double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_x(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_x(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_xmax(maevsi.box3d); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_xmax(maevsi.box3d) FROM PUBLIC;


--
-- Name: FUNCTION st_xmin(maevsi.box3d); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_xmin(maevsi.box3d) FROM PUBLIC;


--
-- Name: FUNCTION st_y(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_y(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_ymax(maevsi.box3d); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_ymax(maevsi.box3d) FROM PUBLIC;


--
-- Name: FUNCTION st_ymin(maevsi.box3d); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_ymin(maevsi.box3d) FROM PUBLIC;


--
-- Name: FUNCTION st_z(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_z(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_zmax(maevsi.box3d); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_zmax(maevsi.box3d) FROM PUBLIC;


--
-- Name: FUNCTION st_zmflag(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_zmflag(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_zmin(maevsi.box3d); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_zmin(maevsi.box3d) FROM PUBLIC;


--
-- Name: FUNCTION trigger_contact_update_account_id(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.trigger_contact_update_account_id() FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.trigger_contact_update_account_id() TO maevsi_account;


--
-- Name: FUNCTION trigger_invitation_update(); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.trigger_invitation_update() FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.trigger_invitation_update() TO maevsi_account;
GRANT ALL ON FUNCTION maevsi.trigger_invitation_update() TO maevsi_anonymous;


--
-- Name: FUNCTION updategeometrysrid(character varying, character varying, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.updategeometrysrid(character varying, character varying, integer) FROM PUBLIC;


--
-- Name: FUNCTION updategeometrysrid(character varying, character varying, character varying, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.updategeometrysrid(character varying, character varying, character varying, integer) FROM PUBLIC;


--
-- Name: FUNCTION updategeometrysrid(catalogn_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.updategeometrysrid(catalogn_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer) FROM PUBLIC;


--
-- Name: TABLE upload; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT ON TABLE maevsi.upload TO maevsi_account;
GRANT SELECT ON TABLE maevsi.upload TO maevsi_anonymous;
GRANT SELECT,DELETE,UPDATE ON TABLE maevsi.upload TO maevsi_tusd;


--
-- Name: FUNCTION upload_create(size_byte bigint); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.upload_create(size_byte bigint) FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi.upload_create(size_byte bigint) TO maevsi_account;


--
-- Name: FUNCTION account_email_address_verification_valid_until(); Type: ACL; Schema: maevsi_private; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi_private.account_email_address_verification_valid_until() FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi_private.account_email_address_verification_valid_until() TO maevsi_account;


--
-- Name: FUNCTION account_password_reset_verification_valid_until(); Type: ACL; Schema: maevsi_private; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi_private.account_password_reset_verification_valid_until() FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi_private.account_password_reset_verification_valid_until() TO maevsi_account;


--
-- Name: FUNCTION events_invited(); Type: ACL; Schema: maevsi_private; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi_private.events_invited() FROM PUBLIC;
GRANT ALL ON FUNCTION maevsi_private.events_invited() TO maevsi_account;
GRANT ALL ON FUNCTION maevsi_private.events_invited() TO maevsi_anonymous;


--
-- Name: FUNCTION account_block_create(_author_account_id uuid, _blocked_account_id uuid); Type: ACL; Schema: maevsi_test; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi_test.account_block_create(_author_account_id uuid, _blocked_account_id uuid) FROM PUBLIC;


--
-- Name: FUNCTION account_block_remove(_author_account_id uuid, _blocked_account_id uuid); Type: ACL; Schema: maevsi_test; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi_test.account_block_remove(_author_account_id uuid, _blocked_account_id uuid) FROM PUBLIC;


--
-- Name: FUNCTION account_create(_username text, _email text); Type: ACL; Schema: maevsi_test; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi_test.account_create(_username text, _email text) FROM PUBLIC;


--
-- Name: FUNCTION account_remove(_username text); Type: ACL; Schema: maevsi_test; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi_test.account_remove(_username text) FROM PUBLIC;


--
-- Name: FUNCTION contact_create(_author_account_id uuid, _email_address text); Type: ACL; Schema: maevsi_test; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi_test.contact_create(_author_account_id uuid, _email_address text) FROM PUBLIC;


--
-- Name: FUNCTION contact_select_by_account_id(_account_id uuid); Type: ACL; Schema: maevsi_test; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi_test.contact_select_by_account_id(_account_id uuid) FROM PUBLIC;


--
-- Name: FUNCTION contact_test(_test_case text, _account_id uuid, _expected_result uuid[]); Type: ACL; Schema: maevsi_test; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi_test.contact_test(_test_case text, _account_id uuid, _expected_result uuid[]) FROM PUBLIC;


--
-- Name: FUNCTION event_category_create(_category text); Type: ACL; Schema: maevsi_test; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi_test.event_category_create(_category text) FROM PUBLIC;


--
-- Name: FUNCTION event_category_mapping_create(_author_account_id uuid, _event_id uuid, _category text); Type: ACL; Schema: maevsi_test; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi_test.event_category_mapping_create(_author_account_id uuid, _event_id uuid, _category text) FROM PUBLIC;


--
-- Name: FUNCTION event_category_mapping_test(_test_case text, _account_id uuid, _expected_result uuid[]); Type: ACL; Schema: maevsi_test; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi_test.event_category_mapping_test(_test_case text, _account_id uuid, _expected_result uuid[]) FROM PUBLIC;


--
-- Name: FUNCTION event_create(_author_account_id uuid, _name text, _slug text, _start text, _visibility text); Type: ACL; Schema: maevsi_test; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi_test.event_create(_author_account_id uuid, _name text, _slug text, _start text, _visibility text) FROM PUBLIC;


--
-- Name: FUNCTION event_test(_test_case text, _account_id uuid, _expected_result uuid[]); Type: ACL; Schema: maevsi_test; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi_test.event_test(_test_case text, _account_id uuid, _expected_result uuid[]) FROM PUBLIC;


--
-- Name: FUNCTION invitation_create(_author_account_id uuid, _event_id uuid, _contact_id uuid); Type: ACL; Schema: maevsi_test; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi_test.invitation_create(_author_account_id uuid, _event_id uuid, _contact_id uuid) FROM PUBLIC;


--
-- Name: FUNCTION invitation_test(_test_case text, _account_id uuid, _expected_result uuid[]); Type: ACL; Schema: maevsi_test; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi_test.invitation_test(_test_case text, _account_id uuid, _expected_result uuid[]) FROM PUBLIC;


--
-- Name: FUNCTION st_3dextent(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_3dextent(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_asflatgeobuf(anyelement); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asflatgeobuf(anyelement) FROM PUBLIC;


--
-- Name: FUNCTION st_asflatgeobuf(anyelement, boolean); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asflatgeobuf(anyelement, boolean) FROM PUBLIC;


--
-- Name: FUNCTION st_asflatgeobuf(anyelement, boolean, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asflatgeobuf(anyelement, boolean, text) FROM PUBLIC;


--
-- Name: FUNCTION st_asgeobuf(anyelement); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asgeobuf(anyelement) FROM PUBLIC;


--
-- Name: FUNCTION st_asgeobuf(anyelement, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asgeobuf(anyelement, text) FROM PUBLIC;


--
-- Name: FUNCTION st_asmvt(anyelement); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asmvt(anyelement) FROM PUBLIC;


--
-- Name: FUNCTION st_asmvt(anyelement, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asmvt(anyelement, text) FROM PUBLIC;


--
-- Name: FUNCTION st_asmvt(anyelement, text, integer); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asmvt(anyelement, text, integer) FROM PUBLIC;


--
-- Name: FUNCTION st_asmvt(anyelement, text, integer, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asmvt(anyelement, text, integer, text) FROM PUBLIC;


--
-- Name: FUNCTION st_asmvt(anyelement, text, integer, text, text); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_asmvt(anyelement, text, integer, text, text) FROM PUBLIC;


--
-- Name: FUNCTION st_clusterintersecting(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_clusterintersecting(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_clusterwithin(maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_clusterwithin(maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: FUNCTION st_collect(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_collect(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_coverageunion(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_coverageunion(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_extent(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_extent(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_makeline(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_makeline(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_memcollect(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_memcollect(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_memunion(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_memunion(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_polygonize(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_polygonize(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_union(maevsi.geometry); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_union(maevsi.geometry) FROM PUBLIC;


--
-- Name: FUNCTION st_union(maevsi.geometry, double precision); Type: ACL; Schema: maevsi; Owner: postgres
--

REVOKE ALL ON FUNCTION maevsi.st_union(maevsi.geometry, double precision) FROM PUBLIC;


--
-- Name: TABLE account; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT ON TABLE maevsi.account TO maevsi_account;
GRANT SELECT ON TABLE maevsi.account TO maevsi_anonymous;


--
-- Name: TABLE account_block; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT,INSERT ON TABLE maevsi.account_block TO maevsi_account;
GRANT SELECT ON TABLE maevsi.account_block TO maevsi_anonymous;


--
-- Name: TABLE account_interest; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT,INSERT,DELETE ON TABLE maevsi.account_interest TO maevsi_account;


--
-- Name: TABLE account_preference_event_size; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT,INSERT,DELETE ON TABLE maevsi.account_preference_event_size TO maevsi_account;


--
-- Name: TABLE account_social_network; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT ON TABLE maevsi.account_social_network TO maevsi_anonymous;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE maevsi.account_social_network TO maevsi_account;


--
-- Name: TABLE achievement; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT ON TABLE maevsi.achievement TO maevsi_account;
GRANT SELECT ON TABLE maevsi.achievement TO maevsi_anonymous;


--
-- Name: TABLE contact; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE maevsi.contact TO maevsi_account;
GRANT SELECT ON TABLE maevsi.contact TO maevsi_anonymous;


--
-- Name: TABLE event_category; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT ON TABLE maevsi.event_category TO maevsi_anonymous;
GRANT SELECT ON TABLE maevsi.event_category TO maevsi_account;


--
-- Name: TABLE event_category_mapping; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT ON TABLE maevsi.event_category_mapping TO maevsi_anonymous;
GRANT SELECT,INSERT,DELETE ON TABLE maevsi.event_category_mapping TO maevsi_account;


--
-- Name: TABLE event_favourite; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT,INSERT,DELETE ON TABLE maevsi.event_favourite TO maevsi_account;


--
-- Name: TABLE event_group; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE maevsi.event_group TO maevsi_account;
GRANT SELECT ON TABLE maevsi.event_group TO maevsi_anonymous;


--
-- Name: TABLE event_grouping; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE maevsi.event_grouping TO maevsi_account;
GRANT SELECT ON TABLE maevsi.event_grouping TO maevsi_anonymous;


--
-- Name: TABLE event_recommendation; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT,INSERT,DELETE ON TABLE maevsi.event_recommendation TO maevsi_account;


--
-- Name: TABLE event_upload; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT,INSERT,DELETE ON TABLE maevsi.event_upload TO maevsi_account;
GRANT SELECT ON TABLE maevsi.event_upload TO maevsi_anonymous;


--
-- Name: TABLE invitation; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE maevsi.invitation TO maevsi_account;
GRANT SELECT,UPDATE ON TABLE maevsi.invitation TO maevsi_anonymous;


--
-- Name: TABLE invitation_flat; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT ON TABLE maevsi.invitation_flat TO maevsi_account;
GRANT SELECT ON TABLE maevsi.invitation_flat TO maevsi_anonymous;


--
-- Name: TABLE legal_term; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT ON TABLE maevsi.legal_term TO maevsi_account;
GRANT SELECT ON TABLE maevsi.legal_term TO maevsi_anonymous;


--
-- Name: TABLE legal_term_acceptance; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT,INSERT ON TABLE maevsi.legal_term_acceptance TO maevsi_account;


--
-- Name: TABLE profile_picture; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE maevsi.profile_picture TO maevsi_account;
GRANT SELECT ON TABLE maevsi.profile_picture TO maevsi_anonymous;
GRANT SELECT,DELETE ON TABLE maevsi.profile_picture TO maevsi_tusd;


--
-- Name: TABLE report; Type: ACL; Schema: maevsi; Owner: postgres
--

GRANT SELECT,INSERT ON TABLE maevsi.report TO maevsi_account;


--
-- Name: TABLE achievement_code; Type: ACL; Schema: maevsi_private; Owner: postgres
--

GRANT SELECT ON TABLE maevsi_private.achievement_code TO maevsi_tusd;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres REVOKE ALL ON FUNCTIONS FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

