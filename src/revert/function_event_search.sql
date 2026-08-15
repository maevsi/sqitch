BEGIN;

DROP FUNCTION vibetype.event_search(TEXT);
DROP FUNCTION vibetype_private.event_search_rank(TEXT);
DROP FUNCTION vibetype_private.tsquery_prefix(regconfig, TEXT);

COMMIT;
