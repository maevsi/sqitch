# `maevsi/sqitch` Basic Project Overview

Welcome! This guide provides a clear understanding of the `maevsi/sqitch` project structure and how to get started effectively.

## Code Structure

The `src` directory contains the Sqitch executable, which you can use to interact with the migrations located in the directory's subdirectories.
The executable is a shell script that invokes Sqitch's Docker image.
When you run `npm run deploy` to deploy the database migrations, this package script invokes the Sqitch executable.

The other files in `src` follow the structure outlined in the [Sqitch documentation](https://sqitch.org/docs/).


## Testing

To run all Sqitch tests, execute:

```sh
npm run test
```

This will:

1. Deploy all migrations, including their verification scripts.
2. Run all tests for the database and data models.
3. Revert all migrations.
4. Check the [schema fixture](#schema-fixture) for any differences.

All tests run in a containerized environment.

<!-- TODO: explain test data directory -->
<!-- TODO: explain test/test.sh -->

### Data for Development

The `npm run test:data:add` command adds basic test data to your working directory.
It copies the `/test/data/*.sql` files to the `/src` subdirectories and appends a line pointing to the test data migration to Sqitch's plan if not added already.

The `npm run test:data:remove` command does the inverse.

> 💡 Adding or removing the test data migration in code does **not** deploy it to or revert it from the database.

### Schema Fixture

Before submitting a pull request, update the schema artifact to ensure consistency by running:

```sh
npm run test:update
```

Be sure to include any resulting changes in your pull request.

<!-- TODO: ## Developer Tooling, explain husky / why node is necessary -->
