-- The database is deliberately kept, since Grafana owns the data in it and this project merely provisions it.
-- Ownership moves to the reverting user so that reverting `role_grafana` afterwards is not blocked by the dependency on its owner.
-- Drop the database manually if it is genuinely no longer needed.
ALTER DATABASE grafana OWNER TO CURRENT_USER;
