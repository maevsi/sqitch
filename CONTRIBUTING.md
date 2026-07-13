# Contributing to `maevsi/sqitch`

First off, thank you for considering contributing to our project! 🎉
We're excited to have you on board and appreciate your effort in helping us improve.
Whether you're a seasoned developer or new to open source, every contribution counts.
This guide will help you get started.

We put continuous effort into making the contribution process as simple as possible.
Please follow the steps below, and if you ever get stuck, don’t hesitate to ask questions – we're here to help!

## Getting Started

### 1. Get to Know This Project

Start by reviewing the following:

- [Quickstart instructions](README.md#quickstart)
- [Onboarding information](README.md#documentation)

These links will help you understand the basics of the project in just a few minutes.

### 2. Clone the Repository

This guide assumes that you're familiar with Git and have cloned the repository or a fork of it to your machine.

**New to Open Source?**
No worries!
Check out [GitHub's Guide to Contributing](https://docs.github.com/en/get-started/quickstart/contributing-to-projects) to learn the basics.

### 3. Make Your Changes

Edit the source code to improve the project.
Be sure to follow any project-specific guidelines.

#### Adding a Database Migration

1. **Naming Convention**: Use descriptive names following patterns:
   - `enum_<type>` for enumerations
   - `function_<name>` for stored functions
   - `role_<name>` for roles
   - `schema_<name>` for schemas
   - `table_<name>` for new tables
   - `table_<name>_policy` for RLS policies
   - `view_<name>` for views

2. **Create Three Files** in the `src/` subdirectories and fill them:
   ```bash
   touch src/deploy/my_feature.sql
   touch src/revert/my_feature.sql
   touch src/verify/my_feature.sql
   ```
3. **Add to Plan**: Append line to `src/sqitch.plan` with dependencies:
   ```
   my_feature [dependency1 dependency2] 1970-01-01T00:00:00Z Your Name <your.email@example.com> # Brief description.
   ```

### 4. Validate Your Changes

Before committing, validate your migration:

```sh
# Run full test suite (deploys, tests, reverts) and updates schema fixtures
npm run test:update
```

The test suite:
1. Deploys all migrations including verification scripts
2. Runs [test/logic/main.sql](test/logic/main.sql) for data validation
3. Reverts all migrations
4. Compares generated schemas against [test/fixture/](test/fixture/) fixtures

If `npm run test` fails with schema differences, review the output and run `npm run test:update` to regenerate fixtures, then commit the updated fixtures with your changes.

### 5. Commit Using Semantic Versioning

Read [@dargmuesli's guide](https://gist.github.com/dargmuesli/430b7d902a22df02d88d1969a22a81b5#file-semantic-versioning-md) on how to correctly format pull request and issue titles and how this necessity speeds up our development.

### 6. Create a Pull Request

<!-- TODO: move up to organization level -->

The creator of a pull request is tasked with ensuring no merge conflicts with the target branch.

**Include in your PR**:
- All three migration files (deploy/revert/verify)
- Updated `src/sqitch.plan`
- Updated schema fixtures from `npm run test:update` (if schema changed)


## Code of Conduct

We expect all contributors to follow our [Code of Conduct](CODE_OF_CONDUCT.md). We’re committed to fostering a welcoming and inclusive environment, and we appreciate your respect for fellow contributors.

---

Thank you again for your interest in contributing. Let’s build something amazing together 🚀
