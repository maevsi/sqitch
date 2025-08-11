BEGIN;

CREATE FUNCTION vibetype.account_blocked_accounts()
RETURNS TABLE (
  id          UUID,
  description TEXT,
  imprint     TEXT,
  username    TEXT,
  storage_key TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.id, a.description, a.imprint, a.username, u.storage_key
    FROM vibetype.account a
      JOIN vibetype.account_block b ON a.id = b.created_by
      LEFT JOIN vibetype.profile_picture p ON p.account_id = a.id
      LEFT JOIN vibetype.upload u ON p.upload_id = u.id
    WHERE a.id = vibetype.invoker_account_id();
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.account_blocked_accounts() IS 'Returns the id, description, imprint, username, and storage key (of profile picture, if it exists) of all accounts blocked by the invoker account.';

GRANT EXECUTE ON FUNCTION vibetype.account_blocked_accounts() TO vibetype_account;

COMMIT;
