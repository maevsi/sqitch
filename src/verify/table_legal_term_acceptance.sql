BEGIN;

SELECT id,
       account_id,
       legal_term_id,
       created_at
FROM maevsi.legal_term_acceptance WHERE FALSE;

\set role_maevsi_tusd_username `cat /run/secrets/postgres_role_maevsi-tusd_username`
SET local role.maevsi_tusd_username TO :'role_maevsi_tusd_username';

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
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.maevsi_tusd_username'), 'maevsi.legal_term_acceptance', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.maevsi_tusd_username'), 'maevsi.legal_term_acceptance', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.maevsi_tusd_username'), 'maevsi.legal_term_acceptance', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.maevsi_tusd_username'), 'maevsi.legal_term_acceptance', 'DELETE'));
END $$;

ROLLBACK;
