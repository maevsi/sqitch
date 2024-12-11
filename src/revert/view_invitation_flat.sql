-- Revert maevsi:view_invitation_flat from pg

BEGIN;

DROP VIEW maevsi.invitation_flat;

COMMIT;
