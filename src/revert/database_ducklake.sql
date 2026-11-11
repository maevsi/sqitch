-- The database is deliberately kept, since the lakehouse owns the catalog data in it and this project merely provisions it.
-- Ownership moves to the reverting user so that reverting `role_gizmosql` afterwards is not blocked by the dependency on its owner.
-- Drop the database manually if it is genuinely no longer needed.
ALTER DATABASE ducklake OWNER TO CURRENT_USER;
