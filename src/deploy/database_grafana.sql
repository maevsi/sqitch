-- Deploy maevsi:database_grafana to pg

CREATE DATABASE grafana;

COMMENT ON DATABASE grafana IS 'The observation dashboard''s database.';
