BEGIN;

CREATE EXTENSION pg_trgm;
COMMENT ON EXTENSION pg_trgm IS 'Provides support for similarity of text using trigram matching, also used for speeding up LIKE queries.';


CREATE INDEX idx_account_username_like ON vibetype.account USING gin(username gin_trgm_ops);
COMMENT ON INDEX vibetype.idx_account_username_like IS 'Index useful for trigram matching as in LIKE/ILIKE conditions on username.';


CREATE FUNCTION vibetype.account_search(
  search_string TEXT
) RETURNS SETOF vibetype.account AS $$
BEGIN
  RETURN QUERY
  SELECT *
  FROM vibetype.account
  WHERE
    username ILIKE '%' || account_search.search_string || '%'
  ORDER BY
    username;
END;
$$ LANGUAGE PLPGSQL STABLE;

COMMENT ON FUNCTION vibetype.account_search(TEXT) IS 'Returns all accounts with a username containing a given substring.';

GRANT EXECUTE ON FUNCTION vibetype.account_search(TEXT) TO vibetype_account;

COMMIT;
