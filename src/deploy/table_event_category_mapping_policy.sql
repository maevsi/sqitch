BEGIN;

GRANT SELECT ON TABLE maevsi.event_category_mapping TO maevsi_anonymous;
GRANT SELECT, INSERT, DELETE ON TABLE maevsi.event_category_mapping TO maevsi_account;

ALTER TABLE maevsi.event_category_mapping ENABLE ROW LEVEL SECURITY;

CREATE POLICY event_category_mapping_select ON maevsi.event_category_mapping FOR SELECT USING (
  -- same policy as for table event
  event_id IN (SELECT id FROM maevsi.event)
);

-- Only allow inserts for events created by user.
CREATE POLICY event_category_mapping_insert ON maevsi.event_category_mapping FOR INSERT WITH CHECK (
  maevsi.invoker_account_id() IS NOT NULL
  AND
  (SELECT created_by FROM maevsi.event WHERE id = event_id) = maevsi.invoker_account_id()
);

-- Only allow deletes for events created by user.
CREATE POLICY event_category_mapping_delete ON maevsi.event_category_mapping FOR DELETE USING (
  maevsi.invoker_account_id() IS NOT NULL
  AND
  (SELECT created_by FROM maevsi.event WHERE id = event_id) = maevsi.invoker_account_id()
);

COMMIT;
