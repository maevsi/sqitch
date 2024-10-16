-- Verify maevsi:table_legal_term_acceptance on pg

BEGIN;

SELECT id,
       created_at,
       account_id,
       legal_term_id
FROM maevsi.legal_term_acceptance WHERE FALSE;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.legal_term_acceptance', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.legal_term_acceptance', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.legal_term_acceptance', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.legal_term_acceptance', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.legal_term_acceptance', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.legal_term_acceptance', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.legal_term_acceptance', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.legal_term_acceptance', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.legal_term_acceptance', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.legal_term_acceptance', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.legal_term_acceptance', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi.legal_term_acceptance', 'DELETE'));
END $$;

ROLLBACK;
