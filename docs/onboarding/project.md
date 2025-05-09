# About this project

Get to know `maevsi/sqitch`'s project layout for a complete onboarding!


## Code Structure

The `src` directory in this repository contains a `sqitch` executable that you can use to interact with the migrations residing in the directory's subdirectories.
For example, when in the `src` directory, run `./sqitch deploy` to fill the database with structure like tables, types and policies.

> 💡 Tip: In case you want to be able to simple call `sqitch deploy` without `./` instead, add an `alias sqitch="./sqitch"` to your shell configuration (`~/.bashrc`, `~/.zshrc`, ...).


## Testing

To run all sqitch tests execute:

```
npx nypm run test
```

This will…

1. deploy all migrations, including all their verifications,
1. run all tests, for database and data models,<!-- TODO: explain test data directory -->
1. revert all migrations,
1. check the [schema fixture](#schema-fixture) for any differences

…all in a container!<!-- TODO: explain test/test.sh -->


### Data for Development

A basic test data migration can be added to your working directory by running `git apply --3way test/data.patch` and deployed as explained in [Code Structure](#code-structure) above.
Changes to the test data can be persisted using `git add -AN && git diff > test/data.patch`.


### Schema Fixture

Before submitting a pull request, it's important to update the schema artifact to ensure consistency. We have a script to make this process easier. Run the following command:

```
npx nypm run test:update
```

Make sure to include these changes in your pull request.

<!-- TODO: ## Developer Tooling, explain husky / why node is necessary -->
