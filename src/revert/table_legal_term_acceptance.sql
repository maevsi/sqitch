BEGIN;

DROP POLICY legal_term_acceptance_insert ON vibetype.legal_term_acceptance;
DROP POLICY legal_term_acceptance_select ON vibetype.legal_term_acceptance;

DROP TABLE vibetype.legal_term_acceptance;

COMMIT;
