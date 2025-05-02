# Row Level Security (PostgreSQL)

> In this document, we present some *Row Level Security (RLS)* features available in PostgreSQL but currently not used in the Vibetype project.

## Disabling RLS

RLS is disabled per table by this command:

```sql
ALTER TABLE <table_name> DISABLE ROW LEVEL SECURITY;
```

## Permissive and restrictive policies

All policies currently defined in *Vibetype* are so-called *permissive* policies, which means that their conditions define a set of rows that are allowed to be selected or modified.

We could explicitly define a policy as *permissive* by adding the `AS PERMISSIVE` clause, e.g.

```sql
CREATE POLICY account_block_all ON vibetype.account_block AS PERMISSIVE FOR ALL
USING (
  created_by = vibetype.invoker_account_id()
);
```

However, this is not done in *Vibetype* since *permissive* is also the default.

While *permissive* policies define conditions telling us which rows should be visible, *restrictive* policies start from a set of visible rows (given by at least one permissive policy) and define conditions telling us which rows should NOT be seen.
In a `CREATE POLICY` statement, the `AS RESTRICTIVE` clause must be used to define a *restrictive* policy.
If multiple restrictive policies apply, they are logically connected by `AND`.

See https://www.postgresql.org/docs/17/sql-createpolicy.html for more details on restrictive policies.
