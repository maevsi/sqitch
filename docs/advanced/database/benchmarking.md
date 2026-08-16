## Query Performance Benchmarking

This project measures the execution time of a fixed set of representative queries and compares pull requests against their merge base, to catch performance regressions before they are merged.

All benchmarking logic lives in `test/benchmark/`:

- `run.sh` seeds a throwaway schema and executes the benchmark queries against whatever database it is pointed at, writing a JSON file of timing results.
- `queries.sql` defines the queries themselves and the measurement logic.
- `seed.sql` populates the `vibetype_test` schema with a fixed amount of test data.
- `compare.sh` diffs two of `run.sh`'s JSON result files and renders a Markdown report.
- `benchmark.sh` is the local entry point that drives the other scripts via Docker.


### What Gets Measured

`queries.sql` defines a `vibetype_test.benchmark_measure()` function that, for each query, discards the first (cold-cache) execution, then re-runs the query repeatedly within a 5-second time budget and records the median timing.
`jit` and `synchronize_seqscans` are disabled for the duration of the run to reduce variance.

Each query in `vibetype_test.benchmark_queries` runs once as `vibetype_anonymous` and once as `vibetype_account`, unless marked `anonymous_only` or `authenticated_only`.
A query that times out (`statement_timeout`) or raises an error is recorded with a sentinel `total_time_ms` (`-1` for timeout, `-2` for error) instead of failing the whole run.


### CI Workflow

`.github/workflows/benchmark.yml` runs on every pull request and posts (or updates) a single PR comment titled "Database Query Performance".

Within one job, on one runner:

1. The PR branch is checked out at the repository root, and the PR's base branch is checked out into `base/`.
2. The base branch's migrations are deployed, and `base/test/benchmark/run.sh` (the base branch's *own* copy of `queries.sql`/`seed.sql`) is run against it, producing `benchmark_base.json`.
3. The base migrations are reverted, the PR's migrations are deployed, and the PR's own `test/benchmark/run.sh` is run against it, producing `benchmark_pr.json`.
4. The PR's `compare.sh` joins both result files by query name and role and renders the comparison as Markdown, which is posted as the PR comment.

Running each side's benchmark with that side's own query definitions (rather than sharing one copy across both schemas) means a query whose signature or return type changed in the PR is never executed against the base schema it's incompatible with.
Base and PR benchmarks are still run back to back in the same job on the same runner, so timing comparisons aren't affected by machine-to-machine variance.


### Reading the Report

- Queries present under the same name and role on both sides get a percentage and absolute delta; a regression is flagged with :warning: when it exceeds both 15% and 1ms, an improvement with :rocket: when it is 15% faster or more.
- Queries with a delta below that threshold are collapsed into a "without a significant delta" details section.
- Queries that only exist on the PR side (new, renamed, or with a changed signature) have no base counterpart to diff against; they are listed in their own "no baseline" section showing only the PR's absolute timing.
- Queries that errored or timed out on either side are counted and shown as `error :x:` / `timeout :hourglass:` instead of a numeric time.


### Running Locally

```sh
test/benchmark/benchmark.sh            # benchmark the current branch and print a results table
test/benchmark/benchmark.sh --compare  # benchmark the current branch against the merge base with main
```

Both modes build the `benchmark` stage of the project `Dockerfile`, which deploys migrations and runs `test/benchmark/run.sh` inside the container at build time, then copies `benchmark_results.json` out of the resulting image.
`--compare` builds this image once per git state (current branch, then the merge base with `main`, via `git checkout`), so each build naturally uses that state's own `test/benchmark/` files, then runs `compare.sh` on the two result files.
