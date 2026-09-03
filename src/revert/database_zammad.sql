-- The database is deliberately kept, since Zammad owns the data in it and this project merely provisions it.
-- Ownership moves to the reverting user so that reverting `role_zammad` afterwards is not blocked by the dependency on its owner.
-- Drop the database manually if it is genuinely no longer needed.
ALTER DATABASE zammad OWNER TO CURRENT_USER;
