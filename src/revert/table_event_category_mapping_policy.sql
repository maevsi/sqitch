BEGIN;

DROP POLICY event_category_mapping_delete ON maevsi.event_category_mapping;
DROP POLICY event_category_mapping_insert ON maevsi.event_category_mapping;
DROP POLICY event_category_mapping_select ON maevsi.event_category_mapping;

COMMIT;
