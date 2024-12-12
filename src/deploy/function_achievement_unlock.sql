BEGIN;

CREATE FUNCTION maevsi.achievement_unlock(
  code UUID,
  alias TEXT
) RETURNS UUID AS $$
DECLARE
  _account_id UUID;
  _achievement maevsi.achievement_type;
  _achievement_id UUID;
BEGIN
  _account_id := maevsi.account_id();

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
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.achievement_unlock(UUID, TEXT) IS 'Inserts an achievement unlock for the user that gave an existing achievement code.';

GRANT EXECUTE ON FUNCTION maevsi.achievement_unlock(UUID, TEXT) TO maevsi_account;

COMMIT;
