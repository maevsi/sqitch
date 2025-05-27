BEGIN;

DROP POLICY legal_term_select ON vibetype.legal_term;

DROP TRIGGER vibetype_legal_term_delete ON vibetype.legal_term;
DROP TRIGGER vibetype_legal_term_update ON vibetype.legal_term;
DROP FUNCTION vibetype.legal_term_change();

DROP TABLE vibetype.legal_term;

COMMIT;
