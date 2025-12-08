BEGIN;

DROP POLICY legal_term_select ON vibetype.legal_term;

DROP TRIGGER delete ON vibetype.legal_term;
DROP TRIGGER update ON vibetype.legal_term;
DROP FUNCTION vibetype.legal_term_change();

DROP TABLE vibetype.legal_term;

COMMIT;
