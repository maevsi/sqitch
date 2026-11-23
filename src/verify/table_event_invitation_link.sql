BEGIN;

SELECT id,
       event_id,
       created_at
FROM vibetype.event_invitation_link WHERE FALSE;

ROLLBACK;

BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.event_invitation_link', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.event_invitation_link', 'event_id', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.event_invitation_link', 'id', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.event_invitation_link', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.event_invitation_link', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.event_invitation_link', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.event_invitation_link', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.event_invitation_link', 'DELETE'));
END $$;

ROLLBACK;
