-- Counts without row level security, so tests can tell a missing row from a hidden one.
CREATE OR REPLACE FUNCTION vibetype_test.account_notification_count (
  _account_id UUID,
  _type TEXT DEFAULT NULL
) RETURNS INTEGER
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT count(*)::INTEGER
  FROM vibetype.account_notification
  WHERE account_id = _account_id
    AND (_type IS NULL OR type = _type::vibetype.notification_type);
$$;

GRANT EXECUTE ON FUNCTION vibetype_test.account_notification_count(UUID, TEXT) TO vibetype_account;


-- Selects without row level security, as the connection role does not inherit the service role's policy.
CREATE OR REPLACE FUNCTION vibetype_test.account_notification_all (
  _filter TEXT DEFAULT 'TRUE'
) RETURNS SETOF vibetype.account_notification
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    AS $$
BEGIN
  RETURN QUERY EXECUTE 'SELECT * FROM vibetype.account_notification WHERE ' || _filter;
END $$;

GRANT EXECUTE ON FUNCTION vibetype_test.account_notification_all(TEXT) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.account_notification_get (
  _account_id UUID,
  _type TEXT
) RETURNS vibetype.account_notification
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT n.*
  FROM vibetype.account_notification n
  WHERE n.account_id = _account_id
    AND n.type = _type::vibetype.notification_type
  ORDER BY (n.read_at IS NULL) DESC, n.created_at DESC
  LIMIT 1;
$$;

GRANT EXECUTE ON FUNCTION vibetype_test.account_notification_get(UUID, TEXT) TO vibetype_account;


-- Runs setup statements that the test role's row level security policies would filter out.
CREATE OR REPLACE FUNCTION vibetype_test.account_notification_exec (
  _statement TEXT
) RETURNS VOID
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
BEGIN
  EXECUTE _statement;
END $$;

GRANT EXECUTE ON FUNCTION vibetype_test.account_notification_exec(TEXT) TO vibetype_account;
