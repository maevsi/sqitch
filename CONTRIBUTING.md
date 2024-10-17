# Contributing to Our Project

First off, thank you for considering contributing to our project! 🎉 We’re excited to have you on board and appreciate the effort you're putting into making our project better. Whether you’re a seasoned developer or a newbie, we believe every contribution counts, and this guide will help you get started.

## Getting Started

We putting continuous effort into making the contribution process as simple as possible. Please follow the steps below, and if you ever get stuck, don’t hesitate to ask questions—we're here to help!

### 1. Fork and Clone the Repository

Start by forking the repository to your GitHub account, and then clone it to your local machine using [Git](https://git-scm.com/):

```
git clone https://github.com/maevsi/sqitch.git
cd maevsi/sqitch
```

### 2. Install Dependencies

After cloning the repository, make sure you install all the required dependencies using [pnpm](https://pnpm.io/):

```
pnpm install
```

### 3. Start the Schema Explorer

<!-- TODO: add a way to check the schema explorer without having to start the full maevsi_stack -->

Head over to [maevsi/maevsi](https://github.com/maevsi/maevsi) to see how to start the full project. Then, you should be able to access the GraphiQL interface at [https://postgraphile.localhost/graphiql](https://postgraphile.localhost/graphiql). This is where you can check that all intended queries and mutations are working as expected.

Please make sure that the queries and mutations listed on the page align with the expected functionality of the project.

### 4. Update Schema Artifacts

Before submitting a pull request, it's important to update the schema artifacts to ensure consistency. We have a script to make this process easier. Run the following command:

```
schema/schema-update.sh
```

This script will regenerate the necessary schema files and update other artifacts as needed. Make sure to include these changes in your pull request.

### 5. Follow Semantic Versioning

We follow [Semantic Versioning](https://semver.org/) in this project. This means:

- **Patch versions** (x.x.1) are for small fixes that don’t affect the API.
- **Minor versions** (x.1.x) are for backward-compatible functionality additions.
- **Major versions** (1.x.x) are for changes that break backward compatibility.

When submitting changes, please ensure your updates and commit messages are aligned with this versioning strategy.

## Contribution Workflow

### 1. Branching

Create a new branch for your work. This keeps your work isolated and makes it easier for others to review.

```
git checkout -b feature/new-feature
```

### 2. Commit Messages

Write clear and concise commit messages that explain the reasoning behind your changes. For example:

- `feat(event)!: remove start time`
- `feat(event): add ticketing`
- `fix(account): correct username length constraint`
- `docs: add contribution guide`


### 3. Pull Requests

When you’re ready to submit your changes, push your branch and open a pull request. In your PR description:

- **Explain the purpose of your changes**: What problem does this solve? Why is this needed?
- **Reference relevant issues**: Link to any GitHub issues this PR addresses.

### 4. Code Reviews

Once your pull request is submitted, someone from the team will review your changes. Be open to feedback! Code reviews are meant to ensure high-quality code and are part of the collaborative development process.

## New to Open Source?

No worries! We’re happy to guide you through the process. Check out [GitHub's Guide to Contributing](https://docs.github.com/en/get-started/quickstart/contributing-to-projects) to get started with open-source contributions.

Feel free to open a draft pull request if you're unsure about anything or if you'd like some early feedback!

## Code of Conduct

We expect all contributors to adhere to our [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before starting any contribution. We aim to foster a welcoming and inclusive community, and we appreciate your respect for fellow contributors.

---

Thank you again for your interest in contributing! Let’s build something amazing together 🚀
