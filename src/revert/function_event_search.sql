BEGIN;

DROP FUNCTION vibetype.event_search(TEXT);
DROP FUNCTION vibetype.event_search_rank(TEXT);
DROP FUNCTION vibetype_private.tsquery_prefix(regconfig, TEXT);

COMMIT;
