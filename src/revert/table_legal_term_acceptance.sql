BEGIN;

DROP POLICY legal_term_acceptance_select ON maevsi.legal_term_acceptance;
DROP POLICY legal_term_acceptance_insert ON maevsi.legal_term_acceptance;

DROP TABLE maevsi.legal_term_acceptance;

COMMIT;
