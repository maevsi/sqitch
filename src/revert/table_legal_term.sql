-- Revert maevsi:table_legal_term from pg

BEGIN;

DROP POLICY legal_term_select ON maevsi.legal_term;
DROP TRIGGER maevsi_legal_term_delete ON maevsi.legal_term;
DROP TRIGGER maevsi_legal_term_update ON maevsi.legal_term;
DROP FUNCTION maevsi.legal_term_change;
DROP TABLE maevsi.legal_term;

COMMIT;
