## Vacuuming the Database

> In this document, we introduce a PostgreSQL-specific feature: the `VACUUM` command.

In PostgreSQL, deleting a record from a table does not lead to its immediate physical deletion.
Instead, the record is marked as deleted.
Similarly, updating a record does not modify the existing record directly; instead, the old record is marked as outdated, and a new record is created.
To avoid wasting disk space, these "dead" records should periodically be physically removed.

This is what the `VACUUM` command does.
The command has several options, which are listed and explained on the official PostgreSQL documentation page: [VACUUM command](https://www.postgresql.org/docs/17/sql-vacuum.html).
The basic concepts are discussed at [Routine Vacuuming](https://www.postgresql.org/docs/17/routine-vacuuming.html).

* The plain `VACUUM` command is usually sufficient to remove dead records from all tables in the current database.
However, it does not return the disk space previously occupied by dead records to the operating system.
Instead, PostgreSQL reuses this space for future `INSERT` or `UPDATE` operations.
The command runs in parallel with regular database operations, but it does impact performance, so the timing of `VACUUM` execution should be carefully planned.

* `VACUUM FULL` is much slower, as it rewrites the entire contents of a table into a new disk file and returns the freed disk space to the operating system.
This operation also requires an `ACCESS EXCLUSIVE` lock on the affected tables.

* `VACUUM ANALYZE` runs the `ANALYZE` command after vacuuming, meaning table statistics are updated.
This is crucial for PostgreSQL to generate optimal execution plans.

A PostgreSQL database server can be configured to run an `autovacuum` daemon.
In the PostgreSQL configuration file (`postgresql.conf`), the daemon is enabled with:

```
autovacuum = on
```

This is also the default setting.
The `autovacuum` daemon automatically runs the `VACUUM ANALYZE` command.

For more details about the `autovacuum` daemon, see:
- [Routine Vacuuming - Autovacuum](https://www.postgresql.org/docs/17/routine-vacuuming.html#AUTOVACUUM)
- [Autovacuum Configuration](https://www.postgresql.org/docs/17/runtime-config-autovacuum.html)

Alternatively, a custom job can be set up to run `VACUUM`, potentially using the [`pg_cron` extension](https://github.com/citusdata/pg_cron).
