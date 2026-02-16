BEGIN;

CREATE TABLE vibetype.event_favorite (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  event_id    UUID NOT NULL REFERENCES vibetype.event(id) ON DELETE CASCADE,

  created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by  UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,

  UNIQUE (created_by, event_id)
);

COMMENT ON TABLE vibetype.event_favorite IS E'@behavior -update\nStores user-specific event favorites, linking an event to the account that marked it as a favorite.';
COMMENT ON COLUMN vibetype.event_favorite.id IS E'@behavior -insert\nPrimary key, uniquely identifies each favorite entry.';
COMMENT ON COLUMN vibetype.event_favorite.event_id IS 'Reference to the event that is marked as a favorite.';
COMMENT ON COLUMN vibetype.event_favorite.created_at IS E'@behavior -insert\nTimestamp when the favorite was created. Defaults to the current timestamp.';
COMMENT ON COLUMN vibetype.event_favorite.created_by IS 'Reference to the account that created the event favorite.';
COMMENT ON CONSTRAINT event_favorite_created_by_event_id_key ON vibetype.event_favorite IS 'Ensures that each user can mark an event as a favorite only once.';

GRANT SELECT ON TABLE vibetype.event_favorite TO vibetype_anonymous;
GRANT SELECT, INSERT, DELETE ON TABLE vibetype.event_favorite TO vibetype_account;

ALTER TABLE vibetype.event_favorite ENABLE ROW LEVEL SECURITY;

CREATE POLICY event_favorite_all ON vibetype.event_favorite FOR ALL
USING (
  created_by = vibetype.invoker_account_id()
);

COMMIT;
