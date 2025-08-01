BEGIN;

-- accept friendship request

CREATE OR REPLACE FUNCTION vibetype.friendship_accept(
  requestor_account_id UUID
) RETURNS VOID AS $$
DECLARE
  _friend_account_id UUID;
  _count INTEGER;
BEGIN

  _friend_account_id := vibetype.invoker_account_id();

  UPDATE vibetype.friendship SET
    status = 'accepted'::vibetype.friendship_status
    -- updated_by filled by trigger
  WHERE account_id = requestor_account_id AND friend_account_id = _friend_account_id
    AND status = 'requested'::vibetype.friendship_status;

  GET DIAGNOSTICS _count = ROW_COUNT;
  IF _count = 0 THEN
    RAISE EXCEPTION 'Friendship request does not exist' USING ERRCODE = 'VTFAC';
  END IF;

  INSERT INTO vibetype.friendship(account_id, friend_account_id, status, created_by)
  VALUES (_friend_account_id, requestor_account_id, 'accepted'::vibetype.friendship_status, _friend_account_id);

END; $$ LANGUAGE plpgsql SECURITY INVOKER;

COMMENT ON FUNCTION vibetype.friendship_accept(UUID) IS 'Accepts a friendship request.\n\nError codes:\n- **VTFAC** when a corresponding friendship request does not exist.';

GRANT EXECUTE ON FUNCTION vibetype.friendship_accept(UUID) TO vibetype_account;

-- reject or cancel friendship

CREATE OR REPLACE FUNCTION vibetype.friendship_cancel(
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

COMMENT ON FUNCTION vibetype.friendship_cancel(UUID) IS 'Rejects or cancels a friendship (in both directions).';

GRANT EXECUTE ON FUNCTION vibetype.friendship_cancel(UUID) TO vibetype_account;

-- create notification for a request

CREATE OR REPLACE FUNCTION vibetype.friendship_notify_request(
  friend_account_id UUID,
  language TEXT
) RETURNS VOID AS $$
BEGIN

  INSERT INTO vibetype_private.notification (channel, payload)
  VALUES (
    'friendship_request',
    jsonb_pretty(jsonb_build_object(
      'data', jsonb_build_object(
        'requestor_account_id', vibetype.invoker_account_id(),
        'requestee_account_id', friendship_notify_request.friend_account_id
      ),
      'template', jsonb_build_object('language', friendship_notify_request.language)
    ))
  );

END; $$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.friendship_notify_request(UUID, TEXT) IS 'Creates a notification for a friendship_request';

GRANT EXECUTE ON FUNCTION vibetype.friendship_notify_request(UUID, TEXT) TO vibetype_account;

-- request friendship

CREATE OR REPLACE FUNCTION vibetype.friendship_request(
  friend_account_id UUID,
  language TEXT
) RETURNS VOID AS $$
DECLARE
  _account_id UUID;
BEGIN

  _account_id := vibetype.invoker_account_id();

  IF EXISTS(
    SELECT 1
    FROM vibetype.friendship f
    WHERE (f.account_id = _account_id AND f.friend_account_id = friendship_request.friend_account_id)
	    OR (f.account_id = friendship_request.friend_account_id AND f.friend_account_id = _account_id)
  )
  THEN
    RAISE EXCEPTION 'Friendship already exists or has already been requested.' USING ERRCODE = 'VTREQ';
  END IF;

  INSERT INTO vibetype.friendship(account_id, friend_account_id, status, created_by)
  VALUES (_account_id, friendship_request.friend_account_id, 'requested'::vibetype.friendship_status, _account_id);

  PERFORM vibetype.friendship_notify_request(friendship_request.friend_account_id, friendship_request.language);

END; $$ LANGUAGE plpgsql SECURITY INVOKER;

COMMENT ON FUNCTION vibetype.friendship_request(UUID, TEXT) IS 'Starts a new friendship request.\n\nError codes:\n- **VTREQ** when the friendship already exists or has already been requested.';

GRANT EXECUTE ON FUNCTION vibetype.friendship_request(UUID, TEXT) TO vibetype_account;


-- toggle closeness of friendship

CREATE OR REPLACE FUNCTION vibetype.friendship_toggle_closeness(
  friend_account_id UUID
) RETURNS BOOLEAN AS $$
DECLARE
  _account_id UUID;
  _is_close_friend BOOLEAN;
  current_status vibetype.friendship_status;
BEGIN

  _account_id := vibetype.invoker_account_id();

  SELECT status INTO current_status
  FROM vibetype.friendship f
  WHERE f.account_id = _account_id AND f.friend_account_id = friendship_toggle_closeness.friend_account_id;

  IF current_status IS NULL OR current_status != 'accepted'::vibetype.friendship_status THEN
    RAISE EXCEPTION 'Friendship does not exist' USING ERRCODE = 'VTFTC';
  END IF;

  UPDATE vibetype.friendship f
  SET is_close_friend = NOT is_close_friend
  WHERE account_id = vibetype.invoker_account_id()
    AND f.friend_account_id = friendship_toggle_closeness.friend_account_id
  RETURNING is_close_friend INTO _is_close_friend;

  RETURN _is_close_friend;

END; $$ LANGUAGE plpgsql SECURITY INVOKER;

COMMENT ON FUNCTION vibetype.friendship_toggle_closeness(UUID) IS 'Toggles a frien1dship relation between ''not a close friend'' and ''close friend''.\n\nError codes:\n- **VTFTC** when the friendship does not exist.';

GRANT EXECUTE ON FUNCTION vibetype.friendship_toggle_closeness(UUID) TO vibetype_account;

COMMIT;
