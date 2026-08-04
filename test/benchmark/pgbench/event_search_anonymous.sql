-- Full-text event search, as an anonymous visitor. Adds a tsvector match on
-- top of the same event_select RLS policy that select_events.sql exercises.
SET ROLE vibetype_anonymous;
SELECT set_config('jwt.claims.sub', '', false);
SELECT * FROM vibetype.event_search('benchmark', 'en');
