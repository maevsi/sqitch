BEGIN;

DROP POLICY legal_term_acceptance_all ON vibetype.legal_term_acceptance;

DROP TABLE vibetype.legal_term_acceptance;

COMMIT;
