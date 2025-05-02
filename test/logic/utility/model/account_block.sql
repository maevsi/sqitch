CREATE OR REPLACE FUNCTION vibetype_test.account_block_create (
  _created_by UUID,
  _blocked_account_id UUID
) RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  SET LOCAL ROLE = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _created_by || '''';

  INSERT INTO vibetype.account_block(created_by, blocked_account_id)
  VALUES (_created_by, _blocked_Account_id)
  RETURNING id INTO _id;

  SET LOCAL ROLE NONE;

  RETURN _id;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.account_block_create(UUID, UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.account_block_delete (
  _created_by UUID,
  _blocked_account_id UUID
) RETURNS VOID AS $$
DECLARE
  _id UUID;
BEGIN
  DELETE FROM vibetype.account_block
  WHERE created_by = _created_by  and blocked_account_id = _blocked_account_id;
END $$ LANGUAGE plpgsql STRICT SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION vibetype_test.account_block_delete(UUID, UUID) TO vibetype_account;
