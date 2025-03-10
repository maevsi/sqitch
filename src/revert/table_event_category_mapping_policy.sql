BEGIN;

DROP POLICY event_category_mapping_delete ON vibetype.event_category_mapping;
DROP POLICY event_category_mapping_insert ON vibetype.event_category_mapping;
DROP POLICY event_category_mapping_select ON vibetype.event_category_mapping;

COMMIT;
