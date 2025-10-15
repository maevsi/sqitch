# Sqitch

[<img src="https://sqitch.org/img/sqitch-logo.svg" alt="Sqitch" width="1000"/>](https://sqitch.org/)

**[Sqitch](https://sqitch.org/)** is the database migration tool driving [Vibetype](https://github.com/maevsi/vibetype).


## 📋 Table of Contents

1. [🛠️ Quickstart](#🛠️-quickstart)
2. [📚 Documentation](#📚-documentation)
3. [🚀 Preview](#🚀-preview)


## 🛠️ Quickstart

Make sure you understand what Sqitch does, i.e. have a look into [Sqitch's documentation](https://sqitch.org/docs/).

This project is designed to be used within the [maevsi/stack](https://github.com/maevsi/stack).
To get started, follow the [Vibetype fullstack setup guide](https://github.com/maevsi/vibetype/blob/main/README.md#fullstack).
Once your development environment is running, use these commands to manage database migrations:

```sh
npm run deploy            # apply database migrations
npm run revert            # roll back database migrations

npm run test              # execute test suite
npm run test:data:add     # add test data migration
npm run test:data:remove  # remove test data migration
npm run test:update       # update test fixtures
```

> ❗ If `npm run deploy` breaks the terminal, try to check for IPv6 incompatibility with `nmcli dev show | grep DNS`. In such a case, commenting out  `::1   localhost` in `/etc/hosts` should allow for a connection with an older protocol.

After setup, you can inspect and test GraphQL queries and mutations using GraphiQL at https://postgraphile.localhost/graphiql.

> 💡 You can run `npm run sqitch <command> [options]` to access full Sqitch functionality.

<!-- TODO: Add a way to inspect the schema without launching the full maevsi/stack. -->

## 📚 Documentation

To fully understand the quick start commands above and Vibetype's database concepts, check out the onboarding and in-depth guides below.

### 🧭 Onboarding

1. **Project**
    1. [Code Structure](./docs/onboarding/project.md)
    1. [Contributing](./CONTRIBUTING.md)
    1. [Code of Conduct](./CODE_OF_CONDUCT.md)
1. **Database concepts**
    1. [Roles](./docs/onboarding/database/roles.md)
    1. [Row Level Security](./docs/onboarding/database/row_level_security.md)

### 🔍 In-Depth Guides

1. **Project**
    1. [Code Structure](./docs/advanced/project.md)
    1. [Changelog](./CHANGELOG.md)
1. **Database concepts**
    1. [Row Level Security](./docs/advanced/database/row_level_security.md)
    1. [Vacuuming](./docs/advanced/database/vacuum.md)

## 🚀 Preview

Here’s a visual overview of what Sqitch creates ([click here to zoom in](https://raw.githubusercontent.com/maevsi/sqitch/refs/heads/main/docs/resources/graph.png)):

[<img src="./docs/resources/graph.png" alt="Database Schema" width="1000"/>](./docs/resources/graph.png)
