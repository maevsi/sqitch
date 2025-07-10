BEGIN;

CREATE FUNCTION vibetype.account_search(
  search_string TEXT
) RETURNS SETOF vibetype.account AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM vibetype.account
  WHERE
    lower(username) LIKE '%' || lower(account_search.search_string) || '%'
  ORDER BY
    username;
END;
$$ LANGUAGE PLPGSQL STABLE;

COMMENT ON FUNCTION vibetype.account_search(TEXT) IS 'Returns all accounts with a username starting with a given prefix.';

GRANT EXECUTE ON FUNCTION vibetype.account_search(TEXT) TO vibetype_account;

COMMIT;
