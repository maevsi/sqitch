# Contributing to Our Project

First off, thank you for considering contributing to our project! 🎉 We’re excited to have you on board and appreciate the effort you're putting into making our project better. Whether you’re a seasoned developer or a newbie, we believe every contribution counts, and this guide will help you get started.

We put continuous effort into making the contribution process as simple as possible. Please follow the steps below, and if you ever get stuck, don’t hesitate to ask questions – we're here to help!


## Getting Started

### 1. Clone this project

This guide assumes that you're familiar with the general usage of git and that you have cloned the repository or a fork of it to your machine.

New to Open Source?
No worries!
Check out [GitHub's Guide to Contributing](https://docs.github.com/en/get-started/quickstart/contributing-to-projects) to get started with open-source contributions.

### 2. Prepare the development environment

<!-- TODO: decide if commit message checks should stay -->

Install [nvm](https://github.com/nvm-sh/nvm?tab=readme-ov-file#install--update-script) to dynamically switch versions of Node.js.
Then run the following commends in the directory that you have cloned the repository into.

```sh
nvm install
corepack enable
pnpm install
```

### 3. Make your changes

Now edit the source code of this project.

### 4. Update Schema Artifacts

Before submitting a pull request, it's important to update the schema artifacts to ensure consistency. We have a script to make this process easier. Run the following command:

```
test/schema/schema-update.sh
```

This script will regenerate the necessary schema files and update other artifacts as needed. Make sure to include these changes in your pull request.

### 5. Create a commit using Semantic Versioning

Read [@dargmuesli's guide](https://gist.github.com/dargmuesli/430b7d902a22df02d88d1969a22a81b5#file-semantic-versioning-md) on how to correctly format pull request, issue and commit titles and how this necessity speeds up our development.

### 6. Create a pull request

<!-- TODO: move up to organization level -->

The creator of a pull request is tasked with ensuring no merge conflicts with the target branch.


## Advanced topics

### Use the Schema Explorer

<!-- TODO: add a way to check the schema explorer without having to start the full maevsi/stack -->

Head over to [maevsi/vibetype](https://github.com/maevsi/vibetype) to see how to start the full project. Then, you should be able to access the GraphiQL interface at [https://postgraphile.localhost/graphiql](https://postgraphile.localhost/graphiql). This is where you can check that all intended queries and mutations are working as expected.

<!-- Please make sure that the queries and mutations listed on the page align with the expected functionality of the project. -->


## Code of Conduct

We expect all contributors to adhere to our [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before starting any contribution. We aim to foster a welcoming and inclusive community, and we appreciate your respect for fellow contributors.

---

Thank you again for your interest in contributing! Let’s build something amazing together 🚀
