-- Returns all attendance ids for guests whose contacts are owned by the given account
CREATE OR REPLACE FUNCTION vibetype_test.attendance_claim_set(
  _account_id UUID
)
RETURNS VOID AS $$
  SELECT vibetype_test.invoker_set(_account_id);

  SELECT set_config(
    'jwt.claims.attendances',
    '[' || COALESCE(
      string_agg('"' || a.id::TEXT || '"', ','),
      ''
    ) || ']',
    true
  )
  FROM vibetype.attendance a
    JOIN vibetype.guest g ON a.guest_id = g.id
    JOIN vibetype.contact c ON g.contact_id = c.id
  WHERE c.account_id = _account_id;

  SELECT vibetype_test.invoker_set_previous();
$$ LANGUAGE SQL;

GRANT EXECUTE ON FUNCTION vibetype_test.attendance_claim_set(UUID) TO vibetype_account;
