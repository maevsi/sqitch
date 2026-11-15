BEGIN;

CREATE FUNCTION vibetype.device_register(
  fcm_token TEXT,
  platform vibetype.device_platform,
  label TEXT DEFAULT NULL
) RETURNS vibetype.device
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
DECLARE
  _account_id UUID := vibetype.invoker_account_id();
  _device vibetype.device;
BEGIN
  IF _account_id IS NULL THEN
    RAISE 'Not signed in!' USING ERRCODE = 'VTDNA';
  END IF;

  -- Shortcut: stale registrations of all accounts are pruned here, on the next registration by anyone.
  -- Upgrade path: a scheduled job, after which this statement can go.
  DELETE FROM vibetype.device WHERE last_seen_at < CURRENT_TIMESTAMP - INTERVAL '90 days';

  INSERT INTO vibetype.device AS d (created_by, fcm_token, label, platform)
  VALUES (_account_id, device_register.fcm_token, device_register.label, device_register.platform)
  ON CONFLICT ON CONSTRAINT device_fcm_token_key DO UPDATE
  SET created_by = EXCLUDED.created_by,
      label = EXCLUDED.label,
      last_seen_at = CURRENT_TIMESTAMP,
      platform = EXCLUDED.platform
  RETURNING d.* INTO _device;

  RETURN _device;
END;
$$;

COMMENT ON FUNCTION vibetype.device_register(TEXT, vibetype.device_platform, TEXT) IS E'Registers a push token for the invoker, or refreshes the registration if the token exists already, taking it over from another account. Also deletes registrations that were not refreshed for 90 days.\n\nError codes:\n- **VTDNA** when there is no invoker account.';

REVOKE ALL ON FUNCTION vibetype.device_register(TEXT, vibetype.device_platform, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION vibetype.device_register(TEXT, vibetype.device_platform, TEXT) TO vibetype_account;

COMMIT;
