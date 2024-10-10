-- Verify maevsi:table_legal_term on pg

BEGIN;

SELECT id,
       created_at,
       language,
       term,
       version
FROM maevsi.legal_term WHERE FALSE;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.legal_term', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.legal_term', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.legal_term', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.legal_term', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.legal_term', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.legal_term', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.legal_term', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.legal_term', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_stomper', 'maevsi.legal_term', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_stomper', 'maevsi.legal_term', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_stomper', 'maevsi.legal_term', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_stomper', 'maevsi.legal_term', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.legal_term', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.legal_term', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.legal_term', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.legal_term', 'DELETE'));

  ASSERT NOT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.legal_term_change()', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.legal_term_change()', 'EXECUTE'));
END $$;

ROLLBACK;
