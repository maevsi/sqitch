BEGIN;

CREATE FUNCTION vibetype.account_search(
  search_string TEXT
) RETURNS SETOF vibetype.account AS $$
  SELECT *
  FROM vibetype.account
  WHERE
    username ILIKE '%' || account_search.search_string || '%'
  ORDER BY
    username;
$$ LANGUAGE sql STABLE;

COMMENT ON FUNCTION vibetype.account_search(TEXT) IS 'Returns all accounts with a username containing a given substring.';

GRANT EXECUTE ON FUNCTION vibetype.account_search(TEXT) TO vibetype_account;

COMMIT;
