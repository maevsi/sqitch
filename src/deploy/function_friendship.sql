BEGIN;

-- accept friendship request

CREATE FUNCTION vibetype.friendship_accept(
  requestor_account_id UUID
) RETURNS VOID AS $$
DECLARE
  _friend_account_id UUID;
  _id UUID;
BEGIN

  _friend_account_id := vibetype.invoker_account_id();

  SELECT id INTO _id
  FROM vibetype.friendship_request
  WHERE account_id = requestor_account_id AND friend_account_id = _friend_account_id;

  IF _id IS NULL THEN
    RAISE EXCEPTION 'Friendship request does not exist' USING ERRCODE = 'VTFAC';
  END IF;

  INSERT INTO vibetype.friendship(account_id, friend_account_id, created_by)
  VALUES (requestor_account_id, _friend_account_id, requestor_account_id);

  INSERT INTO vibetype.friendship(account_id, friend_account_id, created_by)
  VALUES (_friend_account_id, requestor_account_id, _friend_account_id);

  INSERT INTO vibetype.friendship_closeness(account_id, friend_account_id, created_by)
  VALUES (requestor_account_id, _friend_account_id, requestor_account_id);

  INSERT INTO vibetype.friendship_closeness(account_id, friend_account_id, created_by)
  VALUES (_friend_account_id, requestor_account_id, _friend_account_id);

  DELETE FROM vibetype.friendship_request
  WHERE account_id = requestor_account_id AND friend_account_id = vibetype.invoker_account_id();

END; $$ LANGUAGE plpgsql SECURITY INVOKER;

COMMENT ON FUNCTION vibetype.friendship_accept(UUID) IS E'Accepts a friendship request.\n\nError codes:\n- **VTFAC** when a corresponding friendship request does not exist.';

GRANT EXECUTE ON FUNCTION vibetype.friendship_accept(UUID) TO vibetype_account;

-- cancel friendship

CREATE FUNCTION vibetype.friendship_cancel(
  friend_account_id UUID
) RETURNS VOID AS $$
DECLARE
  _account_id UUID;
BEGIN

  _account_id := vibetype.invoker_account_id();

  DELETE FROM vibetype.friendship f
  WHERE (account_id = _account_id AND f.friend_account_id = friendship_cancel.friend_account_id)
    OR (account_id = friendship_cancel.friend_account_id AND f.friend_account_id = _account_id);

END; $$ LANGUAGE plpgsql SECURITY INVOKER;

COMMENT ON FUNCTION vibetype.friendship_cancel(UUID) IS 'Cancels a friendship (in both directions) if it exists.';

GRANT EXECUTE ON FUNCTION vibetype.friendship_cancel(UUID) TO vibetype_account;

-- reject friendship request

CREATE FUNCTION vibetype.friendship_reject(
  requestor_account_id UUID
) RETURNS VOID AS $$
BEGIN

  DELETE FROM vibetype.friendship_request
  WHERE account_id = requestor_account_id AND friend_account_id = vibetype.invoker_account_id();

END; $$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.friendship_reject(UUID) IS 'Rejects a friendship request';

GRANT EXECUTE ON FUNCTION vibetype.friendship_reject(UUID) TO vibetype_account;

-- request friendship

CREATE FUNCTION vibetype.friendship_request(
  friend_account_id UUID
) RETURNS VOID AS $$
DECLARE
  _account_id UUID;
  _language TEXT;
BEGIN

  _account_id := vibetype.invoker_account_id();

  IF _account_id IN (SELECT id FROM vibetype_private.account_block_ids())
    OR friend_account_id IN (SELECT id FROM vibetype_private.account_block_ids()) THEN
    RETURN;
  END IF;

  IF EXISTS(
    SELECT 1
    FROM vibetype.friendship f
    WHERE (f.account_id = _account_id AND f.friend_account_id = friendship_request.friend_account_id)
  )
  THEN
    RAISE EXCEPTION 'Friendship already exists.' USING ERRCODE = 'VTFEX';
  END IF;

  IF EXISTS(
    SELECT 1
    FROM vibetype.friendship_request r
    WHERE (r.account_id = _account_id AND r.friend_account_id = friendship_request.friend_account_id)
      OR (r.account_id = friendship_request.friend_account_id AND r.friend_account_id = _account_id)
  )
  THEN
    RAISE EXCEPTION 'There is already a friendship request.' USING ERRCODE = 'VTREQ';
  END IF;

  INSERT INTO vibetype.friendship_request(account_id, friend_account_id, created_by)
  VALUES (_account_id, friendship_request.friend_account_id, _account_id);

  SELECT COALESCE(language::TEXT, 'de') INTO _language
  FROM vibetype.contact
  WHERE account_id = _account_id AND created_by = _account_id;

  INSERT INTO vibetype_private.notification (channel, payload)
  VALUES (
    'friendship_request',
    jsonb_pretty(jsonb_build_object(
      'data', jsonb_build_object(
        'requestor_account_id', vibetype.invoker_account_id(),
        'requestee_account_id', friendship_request.friend_account_id
      ),
      'template', jsonb_build_object('language', _language)
    ))
  );

END; $$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.friendship_request(UUID) IS E'Starts a new friendship request.\n\nError codes:\n- **VTFEX** when the friendship already exists.\n- **VTREQ** when there is already a friendship request.';

GRANT EXECUTE ON FUNCTION vibetype.friendship_request(UUID) TO vibetype_account;


-- toggle closeness of friendship

CREATE FUNCTION vibetype.friendship_toggle_closeness(
  friend_account_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
  _account_id UUID;
  _result BOOLEAN;
  _is_close_friend BOOLEAN;
BEGIN

  _account_id := vibetype.invoker_account_id();

  SELECT TRUE
  INTO _result
  FROM vibetype.friendship f
  WHERE f.account_id = _account_id
    AND f.friend_account_id = friendship_toggle_closeness.friend_account_id;

  IF _result IS NULL THEN
    RAISE EXCEPTION 'Friendship does not exist' USING ERRCODE = 'VTFTC';
  END IF;

  UPDATE vibetype.friendship_closeness f
  SET is_close_friend = NOT is_close_friend
  WHERE account_id = vibetype.invoker_account_id()
    AND f.friend_account_id = friendship_toggle_closeness.friend_account_id
  RETURNING is_close_friend INTO _is_close_friend;

  RETURN _is_close_friend;

END; $$ LANGUAGE plpgsql SECURITY INVOKER;

COMMENT ON FUNCTION vibetype.friendship_toggle_closeness(UUID) IS E'Toggles a friendship relation between ''not a close friend'' and ''close friend''.\n\nError codes:\n- **VTFTC** when the friendship does not exist.';

GRANT EXECUTE ON FUNCTION vibetype.friendship_toggle_closeness(UUID) TO vibetype_account;

COMMIT;
