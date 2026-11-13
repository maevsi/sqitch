BEGIN;

CREATE OR REPLACE FUNCTION vibetype.account_search(query text) RETURNS SETOF vibetype.account
    LANGUAGE sql STABLE
    AS $$
  SELECT *
  FROM vibetype.account
  WHERE
    username ILIKE '%' || account_search.query || '%'
  ORDER BY
    similarity(username, account_search.query) DESC,
    username;
$$;

DROP FUNCTION vibetype.account_search_match(TEXT);

COMMIT;
