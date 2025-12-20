BEGIN;

CREATE FUNCTION vibetype.account_search(search_string text) RETURNS SETOF vibetype.account
    LANGUAGE sql STABLE
    AS $$
  SELECT *
  FROM vibetype.account
  WHERE
    username ILIKE '%' || account_search.search_string || '%'
  ORDER BY
    username;
$$;

COMMENT ON FUNCTION vibetype.account_search(TEXT) IS 'Returns all accounts with a username containing a given substring.';

GRANT EXECUTE ON FUNCTION vibetype.account_search(TEXT) TO vibetype_account;

COMMIT;
