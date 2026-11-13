BEGIN;

COMMENT ON FUNCTION vibetype.account_search_match(TEXT) IS E'@omit\nReturns ids of accounts with a username containing the given substring, excluding accounts blocked by or blocking the invoker, with their trigram similarity to the query.';
COMMENT ON FUNCTION vibetype.event_search_rank(TEXT) IS E'@omit\nReturns event ids matching the given query by prefix, across every text search configuration event_search_vector rows are stored in, with their relevance rank.';

COMMIT;
