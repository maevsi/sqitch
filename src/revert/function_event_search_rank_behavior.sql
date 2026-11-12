BEGIN;

COMMENT ON FUNCTION vibetype.event_search_rank(TEXT) IS E'@omit\nReturns event ids matching the given query by prefix, across every text search configuration event_search_vector rows are stored in, with their relevance rank.';

COMMIT;
