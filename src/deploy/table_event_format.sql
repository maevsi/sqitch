BEGIN;

CREATE TABLE vibetype.event_format(
  id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name  TEXT NOT NULL,

  CONSTRAINT event_format_name_unique UNIQUE(name)
);

COMMENT ON TABLE vibetype.event_format IS E'@behavior -insert -update -delete\nEvent formats.';
COMMENT ON COLUMN vibetype.event_format.id IS 'The id of the event format.';
COMMENT ON COLUMN vibetype.event_format.name IS 'The name of the event format.';

\set role_service_reccoom_username `cat /run/secrets/postgres_role_service_reccoom_username`

GRANT SELECT ON TABLE vibetype.event_format TO vibetype_anonymous;
GRANT SELECT ON TABLE vibetype.event_format TO vibetype_account;
GRANT SELECT ON TABLE vibetype.event_format TO :role_service_reccoom_username;

-- no row level security necessary for this table as it does not contain user data

END;
