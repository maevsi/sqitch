## Concurrent load benchmark (pgbench)

These are [pgbench](https://www.postgresql.org/docs/current/pgbench.html) transaction scripts, run by `test/benchmark/load.sh`. They're a different tool for a different question than the rest of `test/benchmark/`:

- `queries.sql` (via `run.sh`/`compare.sh`) answers "did this PR make a specific query slower", with a single connection and every trick available to reduce noise (JIT off, cold run discarded, median of N). It runs on every PR and gates on regressions.
- This directory answers "how does the database hold up under concurrent access", which single-client timing structurally cannot show: lock contention, per-row RLS re-evaluation cost, connection/checkpoint interference. It does **not** run on every PR (concurrent throughput on shared GitHub Actions runners is too noisy to gate on) and reports numbers to be read as a trend over time, not diffed strictly run-to-run.

### Why every script sets its own role

`pgbench` opens one persistent connection per client (`-c`) and, when given multiple `-f file@weight` scripts, picks one at random for each transaction on that same connection. A connection that ran `account_search_account.sql` last iteration and `select_events_anonymous.sql` this iteration would otherwise still be `SET ROLE vibetype_account` from before. So every script explicitly sets its role and `jwt.claims.sub` at the top, even the anonymous ones, instead of relying on the connection's state.

All scripts connect as the `postgraphile` role and `SET ROLE` into `vibetype_account`/`vibetype_anonymous` from there, exactly like PostGraphile itself does in production (see `src/deploy/role_account.sql`/`role_anonymous.sql`, which grant `postgraphile` membership in both).

### `:account_id` / `:event_id`

`load.sh` resolves these once (the `benchmark-user-1` account and `benchmark-event-1` event created by `../seed.sql`) and passes them in via `pgbench --define`, so scripts reference `:account_id`/`:event_id` rather than looking them up per iteration. Unlike `psql`, `pgbench` doesn't support the quoted `:'var'` substitution form, it's pure unquoted text substitution, so scripts that need a string literal write their own quotes around the bare token (e.g. `':account_id'`, not `:'account_id'`).

### Adding a script

Follow the pattern of an existing file: `SET ROLE`, `SELECT set_config('jwt.claims.sub', ...)`, then the query. Add it to the `pgbench --file=...@weight` list in `load.sh` with a weight roughly proportional to how often you'd expect that flow in real traffic.

Only call functions/tables the target role is actually granted access to as an end user. `vibetype_private.*` functions can't be called directly this way even when `EXECUTE` is granted, since `vibetype_account`/`vibetype_anonymous` have no `USAGE` on the `vibetype_private` schema by design (see `AGENTS.md`); they're only reachable inlined into a policy or another function, and get exercised indirectly through whatever public entry point uses them (see `select_events_anonymous.sql` for the `events_invited()` example).
