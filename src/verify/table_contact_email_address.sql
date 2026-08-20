BEGIN;

SELECT contact_id, email_address_id, is_primary FROM vibetype.contact_email_address WHERE FALSE;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.contact_email_address', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.contact_email_address', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.contact_email_address', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.contact_email_address', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.contact_email_address', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.contact_email_address', 'INSERT'));

  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype_private.email_address', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype_private.email_address', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_schema_privilege('vibetype_account', 'vibetype_private', 'USAGE'));
  ASSERT (SELECT pg_catalog.has_schema_privilege('vibetype_anonymous', 'vibetype_private', 'USAGE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_private.email_address_readable(UUID)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype_private.email_address_readable(UUID)', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype_private.account_email_address', 'SELECT'));
END $$;

ROLLBACK;
