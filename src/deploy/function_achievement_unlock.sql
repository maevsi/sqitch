BEGIN;

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

COMMENT ON FUNCTION vibetype.achievement_unlock(UUID, TEXT) IS 'Inserts an achievement unlock for the user that gave an existing achievement code.\n\nError codes:\n- **P0002** when the achievement or the account is unknown.';

GRANT EXECUTE ON FUNCTION vibetype.achievement_unlock(UUID, TEXT) TO vibetype_account;

COMMIT;
