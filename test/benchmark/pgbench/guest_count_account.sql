-- Parameterized read: guest count for a single event, as a logged-in
-- account.
SET ROLE vibetype_account;
SELECT set_config('jwt.claims.sub', ':account_id', false);
SELECT vibetype.guest_count(':event_id'::uuid);
