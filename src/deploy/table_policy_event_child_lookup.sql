BEGIN;

-- `EXISTS (SELECT 1 FROM vibetype.event ...)` in a policy is not pulled up into
-- a join. PostgreSQL turns it into an `= ANY` over a hashed subplan, which
-- reads and filters every event visible to the invoker before the first child
-- row is returned: a `LIMIT 20` on `event_upload` cost as much as there are
-- visible events, whatever the filter on the child table.
--
-- `OFFSET 0` keeps the planner from converting the subquery, so each child row
-- instead looks up its one event by primary key (or, for `address`, by
-- `idx_event_address_id`) and applies the `event` policies to that single row.
-- Which rows are visible is unchanged, because `event` is still read through
-- its own policies. Reading all rows costs one lookup per row instead of one
-- hash pass, so `count(*)` over these tables gets slower, and so does an
-- unfiltered read as an invoker who can see only few of the rows.

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
      OFFSET 0
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
    OFFSET 0
  )
);

CREATE POLICY event_category_mapping_select ON vibetype.event_category_mapping FOR SELECT
USING (
  -- same policy as for table event
  EXISTS (
    SELECT 1 FROM vibetype.event e WHERE e.id = event_category_mapping.event_id OFFSET 0
  )
);

-- Only allow selects for accessible events.
CREATE POLICY event_format_mapping_select ON vibetype.event_format_mapping FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM vibetype.event e WHERE e.id = event_format_mapping.event_id OFFSET 0
  )
);

-- Only select rows for accessible events where accessibility is specified
-- by the event_select policy for table event.
CREATE POLICY event_upload_select ON vibetype.event_upload FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM vibetype.event e
    WHERE e.id = event_upload.event_id
    OFFSET 0
  )
);

COMMIT;
