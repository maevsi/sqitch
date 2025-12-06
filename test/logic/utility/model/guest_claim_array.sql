-- Returns all guest ids that represent invitations received by the given account
CREATE OR REPLACE FUNCTION vibetype_test.guest_claim_set(
  _account_id UUID
)
RETURNS VOID AS $$
  SELECT vibetype_test.invoker_set(_account_id);

  SELECT set_config(
    'jwt.claims.guests',
    '[' || COALESCE(
      string_agg('"' || g.id::TEXT || '"', ','),
      ''
    ) || ']',
    true
  )
  FROM vibetype.guest g
    JOIN vibetype.contact c ON g.contact_id = c.id
  WHERE c.account_id = _account_id;

  SELECT vibetype_test.invoker_set_previous();
$$ LANGUAGE SQL;

GRANT EXECUTE ON FUNCTION vibetype_test.guest_claim_set(UUID) TO vibetype_account;

-- CREATE OR REPLACE FUNCTION vibetype_test.guest_claim_set_empty()
-- RETURNS VOID AS $$
-- BEGIN
--   EXECUTE 'SET LOCAL jwt.claims.guests = ''[]''';
-- END $$ LANGUAGE plpgsql;

-- GRANT EXECUTE ON FUNCTION vibetype_test.guest_claim_set_empty() TO vibetype_account;
