CREATE OR REPLACE FUNCTION vibetype_test.invoker_set (
  _invoker_id UUID
)
RETURNS VOID AS $$
BEGIN
  SET LOCAL ROLE = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _invoker_id || '''';
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.invoker_set(UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.invoker_set_anonymous ()
RETURNS VOID AS $$
BEGIN
  SET LOCAL ROLE = 'vibetype_anonymous';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''''';
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.invoker_set_anonymous() TO vibetype_account, vibetype_anonymous;


CREATE OR REPLACE FUNCTION vibetype_test.invoker_set_empty ()
RETURNS VOID AS $$
BEGIN
  SET LOCAL ROLE NONE;
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''''';
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.invoker_set_empty() TO vibetype_account;
