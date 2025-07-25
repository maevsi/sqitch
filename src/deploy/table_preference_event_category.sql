BEGIN;

CREATE TABLE vibetype.preference_event_category (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  account_id  UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES vibetype.event_category(id) ON DELETE CASCADE,

  created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

  UNIQUE (account_id, category_id)
);

COMMENT ON TABLE vibetype.preference_event_category IS 'Event categories a user account is interested in (M:N relationship).';
COMMENT ON COLUMN vibetype.preference_event_category.account_id IS 'A user account id.';
COMMENT ON COLUMN vibetype.preference_event_category.category_id IS 'An event category id.';

GRANT SELECT, INSERT, DELETE ON TABLE vibetype.preference_event_category TO vibetype_account;

ALTER TABLE vibetype.preference_event_category ENABLE ROW LEVEL SECURITY;

CREATE POLICY preference_event_category_all ON vibetype.preference_event_category FOR ALL
USING (
  account_id = vibetype.invoker_account_id()
);

COMMIT;
