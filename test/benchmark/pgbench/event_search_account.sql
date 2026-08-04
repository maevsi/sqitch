-- Full-text event search, as a logged-in account. Adds a tsvector match on
-- top of the same event_select RLS policy that select_events.sql exercises.
SET ROLE vibetype_account;
SELECT set_config('jwt.claims.sub', ':account_id', false);
SELECT * FROM vibetype.event_search('benchmark', 'en');
