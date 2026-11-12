# `maevsi/sqitch` Advanced Project Overview

This document provides advanced project documentation that goes beyond the initial onboarding process.


## Standalone Setup

Besides using the default development environment via [`maevsi/stack`](https://github.com/maevsi/stack), you can also configure a local standalone PostgreSQL database for use with Sqitch.

This standalone setup is lighter but requires you to manually configure local services that are compatible with the `maevsi/stack` production deployment setup.


## Executable

Instead of using the package script (`pnpm run deploy`) to invoke Sqitch, you can call the Sqitch executable directly:

```sh
./src/sqitch deploy <command> [options]
```


## Database Diagram

The database structure diagram embedded in the [main README](../../README.md) is generated using [SchemaCrawler](https://www.schemacrawler.com/).

The [`Graph` workflow](../../.github/workflows/graph.yml) regenerates it on every push to `main` that touches `src/` and opens a pull request when the diagram changed.
It deploys the migrations to a throwaway database and renders `docs/resources/graph.png` with SchemaCrawler.
Because the PNG differs on every render, the committed `docs/resources/graph.dot` (without its timestamp) decides whether the diagram changed.

To update the diagram on demand, run the workflow manually via its `workflow_dispatch` trigger.
