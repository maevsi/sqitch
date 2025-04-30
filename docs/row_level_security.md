# Row Level Security in Vibetype (PostgreSQL)

> In this document, we present the *row level security* concept of PostgreSQL and how it is used in the Vibetype project.

*Row Level Security (RLS)* is a PostgreSQL-specific feature that allows us to define *(row security) policies* that enforce restrictions on which rows in a table can be selected or manipulated by a *Data Manipulation Language (DML)* command.
This is done by defining conditions that must be fulfilled when executing one of the actions `SELECT`, `INSERT`, `UPDATE`, or `DELETE`.

See https://www.postgresql.org/docs/17/ddl-rowsecurity.html for a more complete introductory overview.

## Enabling RLS and creating policies

RLS is enabled per table by this command:

```sql
ALTER TABLE <table_name> ENABLE ROW LEVEL SECURITY;
```

When RLS is initially enabled for a table, all content of the table is hidden, and no DML commands will succeed.

The `CREATE POLICY` command is used to define policies that make the relevant part of the table's content visible and allow inserting, updating, and deleting rows in a restrictive way as defined by the policy's condition.

Conditions can be defined in two ways:

* `USING ( condition )`: a condition to be used by queries (either `SELECT` queries or the queries to be executed for `UPDATE` or `DELETE` commands)

* `WITH CHECK ( condition )`: a condition to be validated at the end of an `INSERT` or `UPDATE` command.

In the `CREATE POLICY` command, you can use `FOR ALL` to make a policy apply to all actions (`SELECT`, `INSERT`, `UPDATE`, or `DELETE`).
Here is an example:

```sql
CREATE POLICY account_block_all ON vibetype.account_block FOR ALL
USING (
  created_by = vibetype.invoker_account_id()
);
```

This policy allows access to only those rows that were created by the current account (which is the account returned by the function call `vibetype.invoker_account_id()`).

The last statement is in fact an abbreviation for:

```sql
CREATE POLICY account_block_all ON vibetype.account_block FOR ALL
USING (
  created_by = vibetype.invoker_account_id()
)
WITH CHECK (
  created_by = vibetype.invoker_account_id()
);
```

A `FOR ALL` policy without an explicit `WITH CHECK` clause implicitly specifies a `WITH CHECK` clause with the same condition as given in the `USING` clause.

It is not always possible to turn conditions into `FOR ALL` policies (although one should try first). Here is an example from *Vibetype* where we had to create policies for each specific action:

```sql
CREATE POLICY event_category_mapping_select ON vibetype.event_category_mapping FOR SELECT USING (
  event_id IN (SELECT id FROM vibetype.event)
);

CREATE POLICY event_category_mapping_insert ON vibetype.event_category_mapping FOR INSERT WITH CHECK (
  (SELECT created_by FROM vibetype.event WHERE id = event_id) = vibetype.invoker_account_id()
);

CREATE POLICY event_category_mapping_delete ON vibetype.event_category_mapping FOR DELETE USING (
  (SELECT created_by FROM vibetype.event WHERE id = event_id) = vibetype.invoker_account_id()
);
```
See https://www.postgresql.org/docs/17/sql-createpolicy.html for more details on the `CREATE POLICY` command and how policies are enforced.

## How are policies enforced?

When a table is accessed by the `SELECT` action, all policies defined for that table and referring to this action are determined, and their `USING` conditions are evaluated for each table row.
If there is more than one policy, the conditions are logically connected by `OR`.
Thus, a row is visible to the query if one of the conditions evaluates to `true`.

When a table is accessed by a specific action (`SELECT`, `INSERT`, `UPDATE`, or `DELETE`), all policies defined for that table and referring to the current action are chosen, and their conditions are evaluated for each row – using `OR` as the logical operator in case more than one policy applies.

With `INSERT` and `UPDATE` commands, the `WITH CHECK` conditions are determined similarly and evaluated against the newly inserted or updated rows.
If the check fails, the statement will fail.

## Policies targeting specific roles

It is possible to create a policy to apply for a specific role (or set of roles) using the `TO <role_name>` clause.
In *Vibetype*, this is rarely done, and most often no `TO` clause will appear (`TO PUBLIC` would have been the explicit way).

Here is an example from *Vibetype*:

```sql
CREATE POLICY upload_all ON vibetype.upload FOR ALL
TO :role_service_vibetype_username
USING (
  TRUE
);

CREATE POLICY upload_select ON vibetype.upload FOR SELECT USING (
    account_id = vibetype.invoker_account_id()
  OR
    id IN (SELECT upload_id FROM vibetype.profile_picture)
);
```

The first policy opens up the complete content of table `upload` to the *Vibetype service* role (user).
The second condition restricts access to all roles. In case the current role is the *Vibetype service* role it does not need to be checked because the first policy with the condition `TRUE` condition also applies and both conditions will be logically connected by `OR`.

## When is RLS not enforced?

Even if RLS is enabled for a table, there are situations when RLS is actually not enforced.
We should be aware of these cases:

* RLS is ignored if the current user (role) is the owner of the table.

* RLS is ignored when a function or procedure is called that was created with `SECURITY DEFINER`.
In this case, they are executed as if called by the user (role) that created the function or procedure.
Usually, this is the same user (role) that owns the application's tables, so RLS is ignored by force of the previous bullet point.

In *Vibetype*, many functions had to be created with `SECURITY DEFINER` because they are used in the conditions of policies.
If they had been created with `SECURITY INVOKER` (which is the alternative option, and the default one), this would have led to a stack overflow due to recursive calls of the function when evaluating the policies' conditions.

Here is an example: In the body of the function `vibetype.guest_claim_array()`, we select from table `vibetype.guest`.
Suppose the function was defined as `SECURITY INVOKER`; this would imply the evaluation of the `USING` condition of the policy defined by `CREATE POLICY guest_select ON vibetype.guest FOR SELECT ...`, which would again call the function `vibetype.guest_claim_array()`, and again there will be a select from table `vibetype.guest`, and so on.

A developer should be careful with `SECURITY DEFINER` functions.
As they bypass RLS security, every security check that would otherwise be handled by policies must be explicitly implemented in the function body.
