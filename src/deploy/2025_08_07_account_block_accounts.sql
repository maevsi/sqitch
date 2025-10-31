BEGIN;

CREATE FUNCTION vibetype.account_block_accounts()
RETURNS TABLE (
  id          UUID,
  username    TEXT,
  storage_key TEXT
) AS $$
BEGIN
  RETURN QUERY
    SELECT a.id, a.username, u.storage_key
    FROM vibetype.account a
      JOIN vibetype.account_block b ON a.id = b.blocked_account_id
      LEFT JOIN vibetype.profile_picture p ON a.id = p.account_id
      LEFT JOIN vibetype.upload u ON p.upload_id = u.id
    WHERE b.created_by = vibetype.invoker_account_id();
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.account_block_accounts() IS 'Returns the id, username, and storage key of the profile picture, if it exists, of all accounts blocked by the invoker account.';

GRANT EXECUTE ON FUNCTION vibetype.account_block_accounts() TO vibetype_account;

COMMIT;
