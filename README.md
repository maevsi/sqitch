# Sqitch

[<img src="https://sqitch.org/img/sqitch-logo.svg" alt="Sqitch" width="1000"/>](https://sqitch.org/)

**[Sqitch](https://sqitch.org/)** is the database migration tool used by [Vibetype](https://github.com/maevsi/vibetype).


## 📋 Table of Contents

1. [🚀 Introduction](#🚀-introduction)
2. [🛠️ Quickstart](#🛠️-quickstart)
3. [📚 Documentation](#📚-documentation)


## 🚀 Introduction

Sqitch automatically sets up your database schema, visualized below ([click here to zoom in](./docs/resources/graph.png)):

[<img src="./docs/resources/graph.png" alt="Database Schema" width="1000"/>](./docs/resources/graph.png)


## 🛠️ Quickstart

This project is designed to be used within the [maevsi/stack](https://github.com/maevsi/stack).
To get started, follow the [Vibetype fullstack setup guide](https://github.com/maevsi/vibetype/blob/main/README.md#fullstack).

Once local development is running, manage migrations using:

<!-- npx nypm install      # Set up or update development tooling -->

```bash
npx nypm run deploy   # apply database migrations
npx nypm run revert   # roll back database migrations
```

> 💡 Tip: You can run `npx nypm run sqitch …` to access full Sqitch functionality.

After setup, you can inspect and test GraphQL queries and mutations using GraphiQL at https://postgraphile.localhost/graphiql.

<!-- TODO: Add a way to inspect the schema without launching the full maevsi/stack. -->

## 📚 Documentation

### Onboarding

Start here for foundational concepts:

1. **Project**
    1. [Code Structure](./docs/onboarding/project.md)
    1. [Contributing](./CONTRIBUTING.md)
    1. [Code of Conduct](./CODE_OF_CONDUCT.md)
1. **Database concepts**
    1. [Roles](./docs/onboarding/database/roles.md)

### In-Depth Guides

Explore advanced topics and deeper insights:

1. **Project**
    1. [Code Structure](./docs/advanced/project.md)
    1. [Changelog](./CHANGELOG.md)
1. **Database concepts**
    1. [Vacuuming](./docs/advanced/database/vacuum.md)
