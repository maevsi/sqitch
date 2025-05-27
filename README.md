# Sqitch

[<img src="https://sqitch.org/img/sqitch-logo.svg" alt="Sqitch" width="1000"/>](https://sqitch.org/)

**[Sqitch](https://sqitch.org/)** is the database migration tool driving [Vibetype](https://github.com/maevsi/vibetype).


## 📋 Table of Contents

1. [🚀 Introduction](#🚀-introduction)
2. [🛠️ Quickstart](#🛠️-quickstart)
3. [📚 Documentation](#📚-documentation)


## 🚀 Introduction

Sqitch sets up your database schema. Here’s a visual overview of what's created ([click here to zoom in](https://raw.githubusercontent.com/maevsi/sqitch/refs/heads/main/docs/resources/graph.png)):

[<img src="./docs/resources/graph.png" alt="Database Schema" width="1000"/>](./docs/resources/graph.png)


## 🛠️ Quickstart

This project is designed to be used within the [maevsi/stack](https://github.com/maevsi/stack).
To get started, follow the [Vibetype fullstack setup guide](https://github.com/maevsi/vibetype/blob/main/README.md#fullstack).

Once your development environment is running, use these commands to manage database migrations:


```bash
npx nypm install  # initial set up & update installation

npm run deploy    # apply database migrations
npm run revert    # roll back database migrations

npm run test      # execute test suite
```

After setup, you can inspect and test GraphQL queries and mutations using GraphiQL at https://postgraphile.localhost/graphiql.

> 💡 Tip: You can run `npm run sqitch <command> [options]` to access full Sqitch functionality.

<!-- TODO: Add a way to inspect the schema without launching the full maevsi/stack. -->

## 📚 Documentation

### 🧭 Onboarding

Kick off your journey with the fundamentals:

1. **Project**
    1. [Code Structure](./docs/onboarding/project.md)
    1. [Contributing](./CONTRIBUTING.md)
    1. [Code of Conduct](./CODE_OF_CONDUCT.md)
1. **Database concepts**
    1. [Roles](./docs/onboarding/database/roles.md)
    1. [Row Level Security](./docs/onboarding/database/row_level_security.md)

### 🔍 In-Depth Guides

Explore advanced topics and deeper insights:

1. **Project**
    1. [Code Structure](./docs/advanced/project.md)
    1. [Changelog](./CHANGELOG.md)
1. **Database concepts**
    1. [Row Level Security](./docs/advanced/database/row_level_security.md)
    1. [Vacuuming](./docs/advanced/database/vacuum.md)
