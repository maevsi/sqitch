## Roles in Vibetype (Postgresql)

> In this document we present the *role* concept of Postgresql and how it is used in the
Vibetype project.

A role is a basic concept of the SQL standard. Interestingly the SQL standard does not speak of
*users*, instead there are *login roles* that can be regarded as users in the ususal sense.
Any database session is opened by a *login role*, usually authenticated by a password.

Access privileges (e.g. selecting from a table or executing a stored function) are assigned to roles (via the `GRANT` statement). All access privileges of a role can be granted to another role with a single `GRANT` statement. We will later see how in a session we can switch between roles and by that ensure that the correct set of access privileges apply depending on the situation.

A role can be marked as a `SUPERUSER`. These roles bypass all access restrictions.
There are also *superusers* that are allowed to create databases and roles.

For Vibetype a specific superuser creates the Vibetype database, the roles and all 
application specific database objects (such as schemas, tables, functions, etc.).
The superuser is the owner of all database objects, which implies that this superuser has all access privileges and bypasses row-level security. The Vibetype application, however, will not connect to the database as this superuser but with other login roles.

In Vibetype we define the following roles and GRANTS between roles:

```sql
-------------------------
-- Superuser (ci in Sqitch)

CREATE ROLE ci WITH SUPERUSER LOGIN PASSWORD '*****' ...;

-------------------------
-- Login roles

CREATE ROLE :role_postgraphile_username LOGIN PASSWORD :'role_vibetype_postgraphile_password';
-- assume 'postgraphile' for :role_postgraphile_username:

CREATE ROLE :role_service_vibetype__username LOGIN PASSWORD :'role_vibetype_password';

GRANT :role_service_vibetype_username TO :role_postgraphile_username
-- assume 'vibetype' for :role_service_vibetype_username

-------------------------
-- other roles

CREATE ROLE vibetype_account;

GRANT vibetype_account to :role_postgraphile_username;

CREATE ROLE vibetype_anonymous;

GRANT vibetype_anonymous to :role_postgraphile_username;
```

So what are the roles `vibetype_account` and `vibetype_anonymous` good for if you
cannot log in as these users?

First of all, access permissions are given excelusively for these two roles. Some examples:

```sql
GRANT EXECUTE ON FUNCTION vibetype.account_delete(TEXT) TO vibetype_account;

GRANT EXECUTE ON FUNCTION vibetype.account_registration_refresh(UUID, TEXT) TO vibetype_anonymous;

GRANT EXECUTE ON FUNCTION vibetype.event_search(TEXT, vibetype.language) TO vibetype_account, vibetype_anonymous;

GRANT SELECT ON TABLE vibetype.address TO vibetype_anonymous;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE vibetype.address TO vibetype_account;
```

After logging in the user can switch to another role. We have just seen that there are
the GRANT statements 

```sql
GRANT vibetype_account to postgraphile;
GRANT vibetype_anonymous to postgraphile;
```

The "long" versions of these statements from above are:

```sql
GRANT vibetype_account to postgraphile WITH INHERIT TRUE, SET TRUE;
GRANT vibetype_anonymous to postgraphile WITH INHERIT TRUE, SET TRUE;
```

* The `INHERIT TRUE` (which is the default) makes all access privileges of the roles`vibetype_account`and `vibetype_anonymous` also be valid for role `postgraphile`.

* The `SET TRUE` (which is the default) allows to "switch" role `postgraphile` to the roles`vibetype_account` or `vibetype_anonymous`.

In order to switch to the role `vibetype_account` the user executes the statement

```sql
SET LOCAL ROLE 'vibetype_account';
```

The `LOCAL` modifier means that the role setting is valid for the current transaction.
When the modifier is omitted (which is equivalent to `SET SESSION`) the role setting applies for the whole session. 

You can switch back to the original role by executing

```sql
SET LOCAL ROLE NONE;
```

This will set the role to the value of `SELECT session_user` which is the login role that started the session.

When a user successfully logs in to the Vibetype app, the database  will return a JWT (JSON Web Token) containing the account id and the name of the role associated with the user. In all subsequent requests, *Postgraphile* does the role switching under the hood based on the content of the current JWT. *Postgraphile* will, by the way, also automatically set the run-time parameter `jwt.claims.account_id` to the account id from the JWT, which corresponds to the command `SET LOCAL 'jwt.claims.account_id' TO '<account_id>'`. If a user is not logged on the the role will be 'vibetype_anonymous'.

Additional remarks:

* A superuser can switch to any role, we don't need a `GRANT <role> TO <superuser>` for that.

* `SET ROLE` cannot be used within a `SECURITY DEFINER` function which is a function that isexecuted with the privileges of the owner of the function.

* See also https://www.postgresql.org/docs/17/sql-createrole.html and https://www.postgresql.org/docs/17/role-membership.html
