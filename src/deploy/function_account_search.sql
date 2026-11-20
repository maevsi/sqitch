BEGIN;

-- Lives in the vibetype schema (not vibetype_private) so vibetype_account can call it with a plain EXECUTE grant, without needing USAGE on vibetype_private; @behavior -* keeps it out of the GraphQL schema.
-- SECURITY DEFINER: the ILIKE match runs as the owner, so the trigram operator is not gated behind the non-leakproof row level security policy of vibetype.account and idx_account_username_like becomes usable.
-- It must therefore exclude the invoker's blocked accounts itself, mirroring the account_select policy, so it never returns an id the invoker may not see; account_search() additionally joins vibetype.account by primary key, which applies the policy to the candidate rows.
CREATE FUNCTION vibetype.account_search_match(query text) RETURNS TABLE(account_id UUID, similarity REAL)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public
    AS $$
  SELECT
    a.id,
    similarity(a.username, account_search_match.query)
  FROM vibetype.account a
  WHERE
    a.username ILIKE '%' || account_search_match.query || '%'
    -- NOT IN over an uncorrelated subquery becomes a hashed subplan evaluated once, rather than calling account_block_ids() per candidate row.
    AND a.id NOT IN (SELECT unnest(vibetype_private.account_block_ids()));
$$;

COMMENT ON FUNCTION vibetype.account_search_match(TEXT) IS E'@behavior -*\nReturns ids of accounts with a username containing the given substring, excluding accounts blocked by or blocking the invoker, with their trigram similarity to the query.';

REVOKE ALL ON FUNCTION vibetype.account_search_match(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION vibetype.account_search_match(TEXT) TO vibetype_account;

CREATE FUNCTION vibetype.account_search(query text) RETURNS SETOF vibetype.account
    LANGUAGE sql STABLE
    AS $$
  SELECT a.*
  FROM vibetype.account_search_match(account_search.query) m
  JOIN vibetype.account a ON a.id = m.account_id
  ORDER BY
    m.similarity DESC,
    a.username;
$$;

COMMENT ON FUNCTION vibetype.account_search(TEXT) IS E'Returns accounts with a username containing a given substring, closest matches first.\nOrdering is fully deterministic, so paginate through results via the GraphQL connection arguments rather than assuming a fixed result size.\nQueries under 3 characters match few trigrams and so scan a larger share of the index; keep that in mind if this backs search-as-you-type.';

GRANT EXECUTE ON FUNCTION similarity(TEXT, TEXT) TO vibetype_account;
GRANT EXECUTE ON FUNCTION vibetype.account_search(TEXT) TO vibetype_account;

COMMIT;
