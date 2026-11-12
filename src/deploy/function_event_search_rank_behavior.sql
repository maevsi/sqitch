BEGIN;

-- `@omit` is a PostGraphile v4 smart tag that v5 ignores without the v4 preset,
-- so this function was part of the GraphQL schema. It bypasses the event
-- policies and must only be reachable through `event_search()`.
COMMENT ON FUNCTION vibetype.event_search_rank(TEXT) IS E'@behavior -*\nReturns event ids matching the given query by prefix, across every text search configuration event_search_vector rows are stored in, with their relevance rank.';

COMMIT;
