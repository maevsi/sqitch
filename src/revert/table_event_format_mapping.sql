BEGIN;

DROP POLICY event_format_mapping_delete ON vibetype.event_format_mapping;
DROP POLICY event_format_mapping_insert ON vibetype.event_format_mapping;
DROP POLICY event_format_mapping_select ON vibetype.event_format_mapping;

DROP TABLE vibetype.event_format_mapping;

COMMIT;
