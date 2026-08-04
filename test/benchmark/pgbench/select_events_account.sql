-- Exercises the event_select RLS policy (src/deploy/table_event_policy.sql)
-- directly, as a logged-in account. See select_events_anonymous.sql for why
-- this is also the suite's coverage of vibetype_private.events_invited().
SET ROLE vibetype_account;
SELECT set_config('jwt.claims.sub', ':account_id', false);
SELECT * FROM vibetype.event;
