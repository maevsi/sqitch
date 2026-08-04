-- Parameterized read: guest count for a single event, as an anonymous
-- visitor.
SET ROLE vibetype_anonymous;
SELECT set_config('jwt.claims.sub', '', false);
SELECT vibetype.guest_count(':event_id'::uuid);
