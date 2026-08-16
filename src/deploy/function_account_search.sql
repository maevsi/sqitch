BEGIN;

CREATE FUNCTION vibetype.account_search(query text) RETURNS SETOF vibetype.account
    LANGUAGE sql STABLE
    AS $$
  SELECT *
  FROM vibetype.account
  WHERE
    username ILIKE '%' || account_search.query || '%'
  ORDER BY
    similarity(username, account_search.query) DESC,
    username
  LIMIT 50;
$$;

COMMENT ON FUNCTION vibetype.account_search(TEXT) IS E'Returns accounts with a username containing a given substring, closest matches first, capped at 50 results.\nQueries under 3 characters match few trigrams and so scan a larger share of the index; keep that in mind if this backs search-as-you-type.';

GRANT EXECUTE ON FUNCTION similarity(TEXT, TEXT) TO vibetype_account, vibetype_anonymous;
GRANT EXECUTE ON FUNCTION vibetype.account_search(TEXT) TO vibetype_account, vibetype_anonymous;

COMMIT;
