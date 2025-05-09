# Roles in Vibetype (PostgreSQL)

> In this document, we present the *role* concept of PostgreSQL and how it is used in the Vibetype project.

A role is a fundamental concept in the SQL standard.
Interestingly, the SQL standard does not use the term *users*; instead, it defines *login roles*, which can be regarded as users in the usual sense.
Any database session is initiated by a *login role*, typically authenticated with a password.

Access privileges (e.g., selecting from a table or executing a stored function) are assigned to roles using the `GRANT` statement.
All access privileges of a role can be granted to another role with a single `GRANT` statement.
Later, we will see how, within a session, we can switch between roles to ensure that the correct set of access privileges applies depending on the situation.

A role can be marked as a `SUPERUSER`.
Such roles bypass all access restrictions.
There are also *superusers* who are allowed to create databases and roles.

In Vibetype, a specific superuser creates the Vibetype database, the roles, and all application-specific database objects (such as schemas, tables, functions, etc.).
The superuser is the owner of all database objects, which means this superuser has all access privileges and bypasses row-level security.
However, the Vibetype application itself does not connect to the database as this superuser but instead uses other login roles.

In Vibetype, we define the following roles and `GRANT` statements between roles:

```sql
-------------------------
-- Superuser (ci in Sqitch)

CREATE ROLE ci WITH SUPERUSER LOGIN PASSWORD '*****' ...;

-------------------------
-- Login roles

CREATE ROLE :role_postgraphile_username LOGIN PASSWORD :'role_vibetype_postgraphile_password';
-- Assume 'postgraphile' for :role_postgraphile_username

CREATE ROLE :role_service_vibetype_username LOGIN PASSWORD :'role_vibetype_password';

GRANT :role_service_vibetype_username TO :role_postgraphile_username;
-- Assume 'vibetype' for :role_service_vibetype_username

-------------------------
-- Other roles

CREATE ROLE vibetype_account;

GRANT vibetype_account TO :role_postgraphile_username;

CREATE ROLE vibetype_anonymous;

GRANT vibetype_anonymous TO :role_postgraphile_username;
```

So what are the roles `vibetype_account` and `vibetype_anonymous` used for if you cannot log in as these users?

First of all, access permissions are granted exclusively to these two roles.
Some examples:

```sql
GRANT EXECUTE ON FUNCTION vibetype.account_delete(TEXT) TO vibetype_account;

GRANT EXECUTE ON FUNCTION vibetype.account_registration_refresh(UUID, TEXT) TO vibetype_anonymous;

GRANT EXECUTE ON FUNCTION vibetype.event_search(TEXT, vibetype.language) TO vibetype_account, vibetype_anonymous;

GRANT SELECT ON TABLE vibetype.address TO vibetype_anonymous;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE vibetype.address TO vibetype_account;
```

After logging in, the user can switch to another role.
We have just seen the `GRANT` statements:

```sql
GRANT vibetype_account TO postgraphile;
GRANT vibetype_anonymous TO postgraphile;
```

The "long" versions of these statements are:

```sql
GRANT vibetype_account TO postgraphile WITH INHERIT TRUE, SET TRUE;
GRANT vibetype_anonymous TO postgraphile WITH INHERIT TRUE, SET TRUE;
```

* The `INHERIT TRUE` (which is the default) ensures that all access privileges of the roles
  `vibetype_account` and `vibetype_anonymous` are also valid for the role `postgraphile`.

* The `SET TRUE` (which is the default) allows the role `postgraphile` to switch to
  `vibetype_account` or `vibetype_anonymous`.

To switch to the role `vibetype_account`, the user executes the statement:

```sql
SET LOCAL ROLE 'vibetype_account';
```

The `LOCAL` modifier means that the role setting is valid only for the current transaction.
If the modifier is omitted (which is equivalent to `SET SESSION`), the role setting applies for the entire session.

To switch back to the original role, execute:

```sql
SET LOCAL ROLE NONE;
```

This resets the role to the value of `SELECT session_user`, which is the login role that started the session.

When a user successfully logs in to the Vibetype app, the database will return a JWT (JSON Web Token) containing the account ID and the name of the role associated with the user.
In all subsequent requests, *Postgraphile* performs the role switching under the hood based on the content of the current JWT.
*Postgraphile* will also automatically set the runtime parameter `jwt.claims.account_id` to the account ID from the JWT, which corresponds to the command `SET LOCAL 'jwt.claims.account_id' TO '<account_id>'`.
If a user is not logged in, the role will be 'vibetype_anonymous'.

## Additional remarks:

* A superuser can switch to any role; we don't need a `GRANT <role> TO <superuser>` for that.
* `SET ROLE` cannot be used within a `SECURITY DEFINER` function, which is a function executed with the privileges of the owner of the function.
* See also [PostgreSQL Documentation on CREATE ROLE](https://www.postgresql.org/docs/17/sql-createrole.html) and [PostgreSQL Documentation on Role Membership](https://www.postgresql.org/docs/17/role-membership.html).
