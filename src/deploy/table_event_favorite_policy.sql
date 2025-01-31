BEGIN;

GRANT SELECT, INSERT, DELETE ON TABLE maevsi.event_favorite TO maevsi_account;

ALTER TABLE maevsi.event_favorite ENABLE ROW LEVEL SECURITY;

-- Only display event favorites that were created by the invoker.
CREATE POLICY event_favorite_select ON maevsi.event_favorite FOR SELECT USING (
  created_by = maevsi.invoker_account_id()
);

-- Only allow inserts for event favorites created by the invoker.
CREATE POLICY event_favorite_insert ON maevsi.event_favorite FOR INSERT WITH CHECK (
  created_by = maevsi.invoker_account_id()
);

-- Only allow deletes for event favorites created by the invoker.
CREATE POLICY event_favorite_delete ON maevsi.event_favorite FOR DELETE USING (
  created_by = maevsi.invoker_account_id()
);

COMMIT;
