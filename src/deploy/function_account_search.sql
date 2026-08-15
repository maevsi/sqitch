BEGIN;

CREATE FUNCTION vibetype.account_search(query text) RETURNS SETOF vibetype.account
    LANGUAGE sql STABLE
    AS $$
  -- Ordering by the <-> distance operator (rather than similarity(...) DESC, which is equivalent but
  -- not index-assisted) lets idx_account_username_trgm's GiST index serve both the WHERE filter and the
  -- ORDER BY in a single index scan, instead of a full sort over every ILIKE-matched row.
  SELECT *
  FROM vibetype.account
  WHERE
    username ILIKE '%' || account_search.query || '%'
  ORDER BY
    username <-> account_search.query,
    username
  LIMIT 50;
$$;

COMMENT ON FUNCTION vibetype.account_search(TEXT) IS E'Returns accounts with a username containing a given substring, closest matches first, capped at 50 results.\nQueries under 3 characters match few trigrams and so scan a larger share of the index; keep that in mind if this backs search-as-you-type.';

GRANT EXECUTE ON FUNCTION similarity_dist(TEXT, TEXT) TO vibetype_account, vibetype_anonymous;
GRANT EXECUTE ON FUNCTION vibetype.account_search(TEXT) TO vibetype_account, vibetype_anonymous;

COMMIT;
