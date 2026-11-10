# `maevsi/sqitch` Basic Project Overview

Welcome! This guide provides a clear understanding of the `maevsi/sqitch` project structure and how to get started effectively.

## Code Structure

The `src` directory contains the Sqitch executable, which you can use to interact with the migrations located in the directory's subdirectories.
The executable is a shell script that invokes Sqitch's Docker image.
When you run `pnpm run deploy` to deploy the database migrations, this package script invokes the Sqitch executable.

The other files in `src` follow the structure outlined in the [Sqitch documentation](https://sqitch.org/docs/):

- **`deploy/`**: SQL files that create or modify database objects
- **`revert/`**: SQL files that undo migrations in reverse order
- **`verify/`**: PL/pgSQL verification scripts with assertions to validate deployment success
- **`sqitch.plan`**: Migration order and dependencies

Each migration has three files; one in each directory. They work together as a unit with Sqitch managing execution order based on dependencies specified in `sqitch.plan`.


## Testing

To run all Sqitch tests, execute:

```sh
pnpm run test
```

This will:

1. Deploy all migrations, including their verification scripts.
2. Run all tests for the database and data models.
3. Revert all migrations.
4. Check the [schema fixture](#schema-fixture) for any differences.

All tests run in a containerized environment.

### Test Directory

The `test` directory holds everything the test commands use:

- **`benchmark/`**: query timing benchmarks, explained in the [benchmarking guide](../advanced/database/benchmarking.md)
- **`data/`**: a deploy, revert and verify script for the test data migration described below
- **`fixture/`**: the expected schema definitions that each test run compares against
- **`logic/`**: SQL tests for the database logic, started from `main.sql`
- **`test.sh`**: the script behind all `test` package scripts

The `test.sh` script builds the Docker image's test stage, which runs the steps listed above.
With `--update`, it builds the stage that generates the schema definitions instead and copies them into `fixture/`.
With `data add` or `data remove`, it only adds or removes the test data migration in your working directory.
It refuses to run the tests while the test data migration is added, because the tests expect an exact set of rows.

### Data for Development

The `pnpm run test:data:add` command adds basic test data to your working directory.
It copies the `/test/data/*.sql` files to the `/src` subdirectories and appends a line pointing to the test data migration to Sqitch's plan if not added already.

The `pnpm run test:data:remove` command does the inverse.

> 💡 Adding or removing the test data migration in code does **not** deploy it to or revert it from the database.

### Schema Fixture

Before submitting a pull request, update the schema artifact to ensure consistency by running:

```sh
pnpm run test:update
```

Be sure to include any resulting changes in your pull request.

## Developer Tooling

Node.js and the package manager only provide the package scripts as short entry points.
The project has no Node.js dependencies, so all actual work happens in Docker containers started by those scripts.
