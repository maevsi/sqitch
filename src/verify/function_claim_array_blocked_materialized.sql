BEGIN;

SELECT vibetype.attendance_claim_array();
SELECT vibetype.guest_claim_array();

ROLLBACK;
