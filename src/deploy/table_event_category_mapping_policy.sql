BEGIN;

GRANT SELECT ON TABLE vibetype.event_category_mapping TO vibetype_anonymous;
GRANT SELECT, INSERT, DELETE ON TABLE vibetype.event_category_mapping TO vibetype_account;

ALTER TABLE vibetype.event_category_mapping ENABLE ROW LEVEL SECURITY;

CREATE POLICY event_category_mapping_select ON vibetype.event_category_mapping FOR SELECT USING (
  -- same policy as for table event
  event_id IN (SELECT id FROM vibetype.event)
);

-- Only allow inserts for events created by user.
CREATE POLICY event_category_mapping_insert ON vibetype.event_category_mapping FOR INSERT WITH CHECK (
  vibetype.invoker_account_id() IS NOT NULL
  AND
  (SELECT created_by FROM vibetype.event WHERE id = event_id) = vibetype.invoker_account_id()
);

-- Only allow deletes for events created by user.
CREATE POLICY event_category_mapping_delete ON vibetype.event_category_mapping FOR DELETE USING (
  vibetype.invoker_account_id() IS NOT NULL
  AND
  (SELECT created_by FROM vibetype.event WHERE id = event_id) = vibetype.invoker_account_id()
);

COMMIT;
