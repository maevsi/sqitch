BEGIN;

CREATE TABLE vibetype.event_category(
  id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name  TEXT NOT NULL,

  CONSTRAINT unique_event_category_name UNIQUE(name)
);

COMMENT ON TABLE vibetype.event_category IS E'@behavior -insert -update -delete\nEvent categories.';
COMMENT ON COLUMN vibetype.event_category.id IS 'The id of the event category.';
COMMENT ON COLUMN vibetype.event_category.name IS 'A category name.';

\set role_service_reccoom_username `cat /run/secrets/postgres_role_service_reccoom_username`

GRANT SELECT ON TABLE vibetype.event_category TO vibetype_anonymous;
GRANT SELECT ON TABLE vibetype.event_category TO vibetype_account;
GRANT SELECT ON TABLE vibetype.event_category TO :role_service_reccoom_username;

-- no row level security necessary for this table as it does not contain user data

END;
