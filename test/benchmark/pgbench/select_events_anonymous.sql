-- Exercises the event_select RLS policy (src/deploy/table_event_policy.sql)
-- directly, as an anonymous visitor. That policy inlines
-- vibetype_private.events_invited() (the example
-- docs/advanced/database/row_level_security.md uses for inlined-vs-wrapped
-- policy cost) per row, so this is also this suite's coverage of that
-- function under load; it can't be called standalone since end-user roles
-- have no USAGE on the vibetype_private schema by design.
-- See README.md for why every script sets its own role.
SET ROLE vibetype_anonymous;
SELECT set_config('jwt.claims.sub', '', false);
SELECT * FROM vibetype.event;
