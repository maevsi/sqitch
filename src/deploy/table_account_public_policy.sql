BEGIN;

GRANT SELECT ON TABLE vibetype.account TO vibetype_account, vibetype_anonymous;
GRANT UPDATE ON TABLE vibetype.account TO vibetype_account;

ALTER TABLE vibetype.account ENABLE ROW LEVEL SECURITY;

-- Make all accounts accessible by everyone.
CREATE FUNCTION vibetype_private.account_policy_select(a vibetype.account)
RETURNS boolean AS $$
  SELECT NOT (a.id = ANY(vibetype_private.account_block_ids()));
$$ LANGUAGE sql STABLE STRICT SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION vibetype_private.account_policy_select(vibetype.account) TO vibetype_account, vibetype_anonymous;

CREATE POLICY account_select ON vibetype.account FOR SELECT
USING (
  vibetype_private.account_policy_select(account)
);

CREATE POLICY account_update ON vibetype.account FOR UPDATE
USING (
  id = vibetype.invoker_account_id()
);

COMMIT;
