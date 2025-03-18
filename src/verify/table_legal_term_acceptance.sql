BEGIN;

SELECT id,
       account_id,
       legal_term_id,
       created_at
FROM vibetype.legal_term_acceptance WHERE FALSE;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.legal_term_acceptance', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.legal_term_acceptance', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.legal_term_acceptance', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.legal_term_acceptance', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.legal_term_acceptance', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.legal_term_acceptance', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.legal_term_acceptance', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.legal_term_acceptance', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.legal_term_acceptance', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.legal_term_acceptance', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.legal_term_acceptance', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_tusd', 'vibetype.legal_term_acceptance', 'DELETE'));
END $$;

ROLLBACK;
