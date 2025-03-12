BEGIN;

GRANT SELECT, INSERT, DELETE ON TABLE vibetype.event_favorite TO vibetype_account;

ALTER TABLE vibetype.event_favorite ENABLE ROW LEVEL SECURITY;

-- Only display event favorites that were created by the invoker.
CREATE POLICY event_favorite_select ON vibetype.event_favorite FOR SELECT USING (
  created_by = vibetype.invoker_account_id()
);

-- Only allow inserts for event favorites created by the invoker.
CREATE POLICY event_favorite_insert ON vibetype.event_favorite FOR INSERT WITH CHECK (
  created_by = vibetype.invoker_account_id()
);

-- Only allow deletes for event favorites created by the invoker.
CREATE POLICY event_favorite_delete ON vibetype.event_favorite FOR DELETE USING (
  created_by = vibetype.invoker_account_id()
);

COMMIT;
