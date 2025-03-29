## Vacuuming the database

> In this document we introduce a Postgresql specific feature, the `VACUUM` command.

In Postgresql a DELETE of a record in a table does not lead to physical deletion of that record, instead the record will be marked as deleted. Likewise, an UPDATE of a record is not executed by modifying the existing record, instead the existing record is marked as uotdated and a new record is created. In order to avoid wasting disk space these "dead"" records should periodically be physically removed.

This is what the `VACUUM` command does. The command comes with a couple of options which are listed and explained on the documentation page of the `VACUUM` command at https://www.postgresql.org/docs/17/sql-vacuum.html. The basic concepts are presented at https://www.postgresql.org/docs/17/routine-vacuuming.html.

* The plain `VACUUM` command is usually sufficient to remove dead records in all tables of the current database. It does not return the disk space formerly occupied by the dead records to the operating system, instead Postgresql will reuse this space for future INSERTs or UPDATEs. The command runs in parallel with the production database operations. IT will have an impact on performance, so the time when to run `VACUUM` should be carefully chosen.

* `VACUUM FULL` is much slower as it rewrites the entire contents of a table into a new disk file and returns the disk space formerly occupied to the operating system. It also requires an `ACCESS EXCLUSIVE` lock on the individual tables.

* `VACUUM ANALYZE` runs the `ANALYZE` command after vacuuming, i.e. table statistics will be updated (which is crucial for Postgresql to generate optimal execution plans)

A Postgresql database server can be started with an `autovacuum` deamon running. In the Postgresql configuration file `postgresql.conf` the deamon is activated by 

```
autovacuum = on
```

(which is also the default). The `autovacuum` deamon runs the `VACUUM ANALYZE` command.

See https://www.postgresql.org/docs/17/routine-vacuuming.html#AUTOVACUUM and https://www.postgresql.org/docs/17/runtime-config-autovacuum.html form more details about the `autovacuum` deamon.

Alternatively a custom-made job could be set up to run `VACUUM`, probably using the [`pg_cron` extension](https://github.com/citusdata/pg_cron).