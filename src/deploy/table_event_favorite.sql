BEGIN;

CREATE TABLE maevsi.event_favorite (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  event_id    UUID REFERENCES maevsi.event(id),

  created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by  UUID REFERENCES maevsi.account(id) NOT NULL,

  UNIQUE (created_by, event_id)
);

COMMENT ON TABLE maevsi.event_favorite IS 'Stores user-specific event favorites, linking an event to the account that marked it as a favorite.';
COMMENT ON COLUMN maevsi.event_favorite.id IS E'@omit create,update\nPrimary key, uniquely identifies each favorite entry.';
COMMENT ON COLUMN maevsi.event_favorite.event_id IS 'Reference to the event that is marked as a favorite.';
COMMENT ON COLUMN maevsi.event_favorite.created_at IS E'@omit create,update\nTimestamp when the favorite was created. Defaults to the current timestamp.';
COMMENT ON COLUMN maevsi.event_favorite.created_by IS E'@omit create,update\nReference to the account that created the event favorite.';
COMMENT ON CONSTRAINT event_favorite_created_by_event_id_key ON maevsi.event_favorite IS 'Ensures that each user can mark an event as a favorite only once.';

-- GRANTs, RLS and POLICYs are specified in 'table_event_favorite_policy`.

COMMIT;
