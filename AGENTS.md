---
applyTo: '**'
---
# Project Instructions
This is a PostgreSQL migration project using [Sqitch](https://sqitch.org/) for schema management. It defines one of many services of `vibetype`, an event community platform. The SQL schema applied by this service is exposed as a GraphQL API by the `postgraphile` service.

## Migration Structure

- Each migration consists of three files in `src/`: `deploy/<name>.sql`, `revert/<name>.sql`, and `verify/<name>.sql`
- Migrations are wrapped in transactions (`BEGIN;`/`COMMIT;`)
- All migrations are tracked in `src/sqitch.plan`

## API Design

- The PostgreSQL schema is exposed as a GraphQL API via PostGraphile v5
- The GraphQL API exposed should have a simple and consistent surface, especially when it comes to naming
- Prefer CRUD behavior and constraints over custom functions, to keep the schema simple and maintainable
- The `vibetype.jwt` composite type defines JWT payload fields; PostGraphile uses it for JWT signing
- Error codes consist of 5 capitalized letters starting with a `VT` prefix: e.g. `VTPLL` for "password length low"

## Security

- `ENABLE ROW LEVEL SECURITY` (RLS) policies to enforce access control on tables
- Grant `EXECUTE` on functions to the appropriate roles only
- Ensure that PostGraphile Smart Comments properly control API exposure
- Prefer `security invoker`; only use `security definer` when necessary
- Use the `vibetype_private` schema for internal logic and especially protected content that should never be exposed directly

## Performance

- Performance is key: always consider query planner optimizations when writing SQL
- Prefer SQL over PL/pgSQL, except where it doesn't make sense
- Foreign keys must have corresponding indexes

## Testing

- Ensure SQL logic is always covered by tests
- Use the test framework in `test/` rather than `src/verify/` scripts
- Prefer the unit test-like SAVEPOINT/ROLLBACK pattern used in existing tests

## Workflow

1. Edit SQL files, keeping the plan in sync
2. Ensure correctness of security and permissions
3. Ensure proper test coverage
4. Run `npm run test:update` to build the Docker test image, deploy all migrations, run test SQL, revert, and update schema fixture files

Note: if branching off of `beta`, migrations can be edited in-place. If branching off of `main`, changes must happen in new migrations only.

## General instructions

- Code style
  - Sort any elements (imports, object properties, functions, ...), e.g. alphabetically, except when it doesn't make sense.
- Agents
  - After making changes to the codebase, ensure AGENTS.md is in sync with your knowledge of the project.
