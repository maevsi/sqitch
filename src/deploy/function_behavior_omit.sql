BEGIN;

-- `@omit` is a PostGraphile v4 smart tag that v5 ignores without the v4 preset,
-- so these functions were part of the GraphQL schema. They run as their owner
-- and must only be reachable through `account_search()` and `event_search()`.
COMMENT ON FUNCTION vibetype.account_search_match(TEXT) IS E'@behavior -*\nReturns ids of accounts with a username containing the given substring, excluding accounts blocked by or blocking the invoker, with their trigram similarity to the query.';
COMMENT ON FUNCTION vibetype.event_search_rank(TEXT) IS E'@behavior -*\nReturns event ids matching the given query by prefix, across every text search configuration event_search_vector rows are stored in, with their relevance rank.';

COMMIT;
