BEGIN;

DROP POLICY address_all ON vibetype.address;
DROP POLICY event_app_select ON vibetype.event_app;
DROP POLICY event_category_mapping_select ON vibetype.event_category_mapping;
DROP POLICY event_format_mapping_select ON vibetype.event_format_mapping;
DROP POLICY event_upload_select ON vibetype.event_upload;

CREATE POLICY address_all ON vibetype.address FOR ALL
USING (
  (
    address.created_by = vibetype.invoker_account_id()
    OR EXISTS (
      SELECT 1
      FROM vibetype.event e
      WHERE e.address_id = address.id
    )
  )
  AND
  NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.account_block_ids())) AS b WHERE b = address.created_by)
)
WITH CHECK (
  address.created_by = vibetype.invoker_account_id()
);

CREATE POLICY event_app_select ON vibetype.event_app FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM vibetype.event e
    WHERE e.id = event_id
  )
);

CREATE POLICY event_category_mapping_select ON vibetype.event_category_mapping FOR SELECT
USING (
  -- same policy as for table event
  EXISTS (
    SELECT 1 FROM vibetype.event e WHERE e.id = event_category_mapping.event_id
  )
);

-- Only allow selects for accessible events.
CREATE POLICY event_format_mapping_select ON vibetype.event_format_mapping FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM vibetype.event e WHERE e.id = event_format_mapping.event_id
  )
);

-- Only select rows for accessible events where accessibility is specified
-- by the event_select policy for table event.
CREATE POLICY event_upload_select ON vibetype.event_upload FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM vibetype.event e
    WHERE e.id = event_upload.event_id
  )
);

COMMIT;
